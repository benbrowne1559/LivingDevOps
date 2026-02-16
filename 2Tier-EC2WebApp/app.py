from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os
from dotenv import load_dotenv
from sqlalchemy import inspect
import boto3
from botocore.exceptions import ClientError
import json

def get_secret():

    secret_name = "public/postgresdb"
    region_name = "eu-north-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = json.loads(get_secret_value_response['SecretString'])
    password = secret['password'] 
    host = secret['host']

    return password, host

load_dotenv('postgres.env')
password, host = get_secret()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key')
app.config['SQLALCHEMY_DATABASE_URI'] = f"postgresql://{os.getenv('DB_USER')}:{password}@{host}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class Subscriber(db.Model):
    __tablename__ = 'subscribers'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False, unique=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# Check if table exists and create if it doesn't
with app.app_context():
    inspector = inspect(db.engine)
    if not inspector.has_table('subscribers'):
        db.create_all()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        
        if not name or not email:
            flash('Please provide both name and email.', 'error')
            return redirect(url_for('signup'))
        
        existing = Subscriber.query.filter_by(email=email).first()
        if existing:
            flash('This email is already subscribed!', 'error')
            return redirect(url_for('signup'))
        
        try:
            new_subscriber = Subscriber(name=name, email=email)
            db.session.add(new_subscriber)
            db.session.commit()
            flash('Successfully subscribed!', 'success')
        except Exception as e:
            db.session.rollback()
            flash(f'An error occurred: {str(e)}', 'error')
        
        return redirect(url_for('signup'))
    
    subscribers = Subscriber.query.order_by(Subscriber.created_at.desc()).all()
    return render_template('signup.html', subscribers=subscribers)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)