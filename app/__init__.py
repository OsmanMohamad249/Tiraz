"""
Taarez Application Factory
تطبيق طراز - Taarez Application
"""
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import os

db = SQLAlchemy()


def create_app(config_name='development'):
    """Create and configure the Flask application"""
    app = Flask(__name__)
    
    # Load configuration
    from config import config
    app.config.from_object(config[config_name])
    
    # Ensure instance folder exists
    os.makedirs(app.instance_path, exist_ok=True)
    
    # Initialize extensions
    db.init_app(app)
    
    # Register blueprints
    from app.controllers import main_controller, item_controller
    app.register_blueprint(main_controller.bp)
    app.register_blueprint(item_controller.bp)
    
    # Register CLI commands
    from app import commands
    commands.register_commands(app)
    
    # Create database tables
    with app.app_context():
        db.create_all()
    
    return app
