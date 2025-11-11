"""
Flask CLI commands for Taarez application
أوامر التطبيق - Taarez CLI Commands
"""
import click
from flask.cli import with_appcontext
from app import db
from app.models import Item


@click.command('trial-run')
@click.option('--clear', is_flag=True, help='Clear existing data before adding sample data')
@with_appcontext
def trial_run_command(clear):
    """
    Populate database with sample data for trial/demo purposes.
    ملء قاعدة البيانات ببيانات تجريبية للعرض التوضيحي
    
    Usage:
        flask trial-run
        flask trial-run --clear
    """
    if clear:
        click.echo('Clearing existing items... / حذف العناصر الموجودة...')
        Item.query.delete()
        db.session.commit()
        click.echo('✓ Existing items cleared / تم حذف العناصر الموجودة')
    
    # Check if sample data already exists
    existing_count = Item.query.count()
    if existing_count > 0 and not clear:
        click.echo(f'Database already contains {existing_count} items.')
        click.echo('Use --clear flag to remove existing data first.')
        return
    
    click.echo('Adding sample data... / إضافة بيانات تجريبية...')
    
    # Sample items with bilingual content
    sample_items = [
        {
            'name': 'ثوب سعودي تقليدي / Traditional Saudi Thobe',
            'description': 'ثوب سعودي أبيض تقليدي مصنوع من قماش قطني عالي الجودة، مثالي للمناسبات الرسمية والاستخدام اليومي',
            'style': 'Traditional'
        },
        {
            'name': 'قميص عصري / Modern Shirt',
            'description': 'قميص رجالي عصري بتصميم أنيق وألوان متنوعة، مناسب للعمل والمناسبات غير الرسمية',
            'style': 'Modern'
        },
        {
            'name': 'ثوب كويتي كلاسيكي / Classic Kuwaiti Dishdasha',
            'description': 'ثوب كويتي كلاسيكي بتطريز دقيق وجودة عالية، يجمع بين الأناقة والراحة',
            'style': 'Classic'
        },
        {
            'name': 'قميص كاجوال / Casual Shirt',
            'description': 'قميص كاجوال مريح مصنوع من أقمشة خفيفة، مثالي للأجواء الدافئة والأنشطة اليومية',
            'style': 'Casual'
        },
        {
            'name': 'جلابية مصرية / Egyptian Galabiya',
            'description': 'جلابية مصرية تقليدية بتصميم واسع ومريح، مصنوعة من قطن خالص',
            'style': 'Traditional'
        },
        {
            'name': 'ثوب إماراتي معاصر / Contemporary Emirati Kandura',
            'description': 'ثوب إماراتي بتصميم معاصر يجمع بين التقليد والحداثة، بجودة فائقة',
            'style': 'Contemporary'
        },
        {
            'name': 'قميص رسمي / Formal Shirt',
            'description': 'قميص رسمي أنيق مناسب للاجتماعات المهنية والمناسبات الرسمية',
            'style': 'Formal'
        },
        {
            'name': 'ثوب صيفي / Summer Thobe',
            'description': 'ثوب صيفي خفيف الوزن مصنوع من أقمشة قطنية تسمح بمرور الهواء للراحة في الأجواء الحارة',
            'style': 'Casual'
        },
        {
            'name': 'قميص مطرز / Embroidered Shirt',
            'description': 'قميص بتطريز يدوي فاخر، يضيف لمسة من الأناقة والتميز',
            'style': 'Luxury'
        },
        {
            'name': 'ثوب شتوي / Winter Thobe',
            'description': 'ثوب شتوي من قماش سميك للدفء في الأجواء الباردة، مع تصميم أنيق ومريح',
            'style': 'Classic'
        }
    ]
    
    # Add items to database
    added_count = 0
    for item_data in sample_items:
        item = Item(**item_data)
        db.session.add(item)
        added_count += 1
    
    db.session.commit()
    
    click.echo(f'✓ Successfully added {added_count} sample items!')
    click.echo(f'✓ تم إضافة {added_count} عنصر تجريبي بنجاح!')
    click.echo('\nTrial run data populated. You can now explore the application.')
    click.echo('تم ملء البيانات التجريبية. يمكنك الآن استكشاف التطبيق.')


def register_commands(app):
    """Register CLI commands with Flask app"""
    app.cli.add_command(trial_run_command)
