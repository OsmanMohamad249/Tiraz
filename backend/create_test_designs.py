#!/usr/bin/env python3
"""
Script to create test designs in the database.
Run this after create_test_users.py.
"""

import sys
import uuid
from sqlalchemy.orm import Session

from core.database import SessionLocal
from models.user import User
from models.roles import UserRole
from models.design import Design
from models.category import Category

def create_test_designs():
    """Create test designs for development."""
    db: Session = SessionLocal()

    try:
        # 1. Find the designer user
        designer = db.query(User).filter(User.email == "designer@example.com").first()
        if not designer:
            print("❌ Designer user not found. Please run create_test_users.py first.")
            return False

        print(f"Found designer: {designer.email}")

        # 2. Create Categories
        categories_data = [
            {"name": "Thobes", "description": "Traditional Thobes", "image_url": "https://placehold.co/400x300?text=Thobes"},
            {"name": "Suits", "description": "Modern Suits", "image_url": "https://placehold.co/400x300?text=Suits"},
            {"name": "Casual", "description": "Casual Wear", "image_url": "https://placehold.co/400x300?text=Casual"},
        ]

        categories = {}
        for cat_data in categories_data:
            cat = db.query(Category).filter(Category.name == cat_data["name"]).first()
            if not cat:
                cat = Category(**cat_data)
                db.add(cat)
                db.flush() # Get ID
                print(f"✅ Created category: {cat.name}")
            else:
                print(f"⏭️  Category {cat.name} already exists")
            categories[cat.name] = cat

        # 3. Create Designs
        designs_data = [
            {
                "name": "Classic White Thobe",
                "description": "A timeless classic white thobe made from premium cotton.",
                "base_price": 150.0,
                "base_image_url": "https://placehold.co/600x800?text=White+Thobe",
                "style_type": "Classic",
                "category_id": categories["Thobes"].id,
                "owner_id": designer.id,
                "is_active": True
            },
            {
                "name": "Modern Navy Suit",
                "description": "Slim fit navy suit suitable for business and formal events.",
                "base_price": 450.0,
                "base_image_url": "https://placehold.co/600x800?text=Navy+Suit",
                "style_type": "Modern",
                "category_id": categories["Suits"].id,
                "owner_id": designer.id,
                "is_active": True
            },
            {
                "name": "Summer Linen Shirt",
                "description": "Breathable linen shirt perfect for hot weather.",
                "base_price": 80.0,
                "base_image_url": "https://placehold.co/600x800?text=Linen+Shirt",
                "style_type": "Casual",
                "category_id": categories["Casual"].id,
                "owner_id": designer.id,
                "is_active": True
            },
             {
                "name": "Embroidered Thobe",
                "description": "Traditional thobe with intricate embroidery details.",
                "base_price": 200.0,
                "base_image_url": "https://placehold.co/600x800?text=Embroidered+Thobe",
                "style_type": "Traditional",
                "category_id": categories["Thobes"].id,
                "owner_id": designer.id,
                "is_active": True
            },
        ]

        created_count = 0
        for design_data in designs_data:
            # Check if exists by name (simple check)
            existing = db.query(Design).filter(Design.name == design_data["name"]).first()
            if not existing:
                design = Design(**design_data)
                db.add(design)
                print(f"✅ Created design: {design.name}")
                created_count += 1
            else:
                print(f"⏭️  Design {design_data['name']} already exists")

        db.commit()
        print(f"\n📊 Summary: Created {created_count} new designs.")
        return True

    except Exception as e:
        print(f"❌ Error creating test designs: {e}")
        db.rollback()
        return False
    finally:
        db.close()

if __name__ == "__main__":
    create_test_designs()
