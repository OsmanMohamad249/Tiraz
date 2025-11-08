"""
Tests for trial run functionality
اختبارات التشغيل التجريبي
"""
import unittest
from flask.cli import FlaskGroup
from app import create_app, db
from app.models import Item
from app.commands import trial_run_command


class TrialRunTestCase(unittest.TestCase):
    """Test cases for trial run functionality"""

    def setUp(self):
        """Set up test client and database"""
        self.app = create_app('testing')
        self.client = self.app.test_client()
        self.app_context = self.app.app_context()
        self.app_context.push()
        db.create_all()

    def tearDown(self):
        """Clean up after tests"""
        db.session.remove()
        db.drop_all()
        self.app_context.pop()

    def test_trial_run_populates_data(self):
        """Test that trial run command populates the database"""
        # Verify database is empty
        self.assertEqual(Item.query.count(), 0)
        
        # Run trial-run command
        runner = self.app.test_cli_runner()
        result = runner.invoke(trial_run_command)
        
        # Check command executed successfully
        self.assertEqual(result.exit_code, 0)
        self.assertIn('Successfully added', result.output)
        
        # Verify items were added
        items = Item.query.all()
        self.assertEqual(len(items), 10)
        
        # Verify sample data has required fields
        for item in items:
            self.assertIsNotNone(item.name)
            self.assertIsNotNone(item.style)
            self.assertTrue(len(item.name) > 0)

    def test_trial_run_with_existing_data(self):
        """Test that trial run prevents duplicate data without --clear flag"""
        # Add an item first
        item = Item(name='Existing Item', description='Test', style='Test')
        db.session.add(item)
        db.session.commit()
        
        # Try to run trial-run without clear flag
        runner = self.app.test_cli_runner()
        result = runner.invoke(trial_run_command)
        
        # Should prevent adding duplicate data
        self.assertEqual(result.exit_code, 0)
        self.assertIn('already contains', result.output)
        self.assertEqual(Item.query.count(), 1)  # Still only 1 item

    def test_trial_run_with_clear_flag(self):
        """Test that trial run clears existing data with --clear flag"""
        # Add an item first
        item = Item(name='Old Item', description='To be cleared', style='Old')
        db.session.add(item)
        db.session.commit()
        self.assertEqual(Item.query.count(), 1)
        
        # Run trial-run with --clear flag
        runner = self.app.test_cli_runner()
        result = runner.invoke(trial_run_command, ['--clear'])
        
        # Check command executed successfully
        self.assertEqual(result.exit_code, 0)
        self.assertIn('Successfully added', result.output)
        
        # Verify old item was cleared and new items added
        items = Item.query.all()
        self.assertEqual(len(items), 10)
        
        # Verify old item is gone
        old_item = Item.query.filter_by(name='Old Item').first()
        self.assertIsNone(old_item)

    def test_trial_run_sample_data_content(self):
        """Test that trial run creates diverse sample data"""
        runner = self.app.test_cli_runner()
        result = runner.invoke(trial_run_command)
        
        self.assertEqual(result.exit_code, 0)
        
        items = Item.query.all()
        
        # Check for diversity in styles
        styles = {item.style for item in items}
        self.assertGreater(len(styles), 3)  # At least 4 different styles
        
        # Check for bilingual content (Arabic/English)
        bilingual_count = sum(1 for item in items if '/' in item.name)
        self.assertGreater(bilingual_count, 5)  # Most items should be bilingual
        
        # Check that items have descriptions
        items_with_descriptions = sum(1 for item in items if item.description)
        self.assertEqual(items_with_descriptions, 10)  # All items should have descriptions

    def test_trial_run_items_are_accessible(self):
        """Test that trial run items can be accessed via the web interface"""
        # Run trial-run command
        runner = self.app.test_cli_runner()
        result = runner.invoke(trial_run_command)
        self.assertEqual(result.exit_code, 0)
        
        # Try to access items list page
        response = self.client.get('/items/')
        self.assertEqual(response.status_code, 200)
        
        # Check that sample items appear on the page
        items = Item.query.all()
        for item in items[:3]:  # Check first 3 items
            # Check that at least part of the name appears
            name_part = item.name.split('/')[0].strip()
            self.assertIn(name_part.encode('utf-8'), response.data)


if __name__ == '__main__':
    unittest.main()
