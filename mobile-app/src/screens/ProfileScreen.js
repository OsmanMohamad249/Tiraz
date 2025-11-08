import React from 'react';
import {View, Text, StyleSheet, ScrollView, TouchableOpacity} from 'react-native';

const ProfileScreen = () => {
  const measurements = [
    {label: 'Chest', value: '98', unit: 'cm'},
    {label: 'Waist', value: '82', unit: 'cm'},
    {label: 'Shoulders', value: '44', unit: 'cm'},
    {label: 'Arm Length', value: '62', unit: 'cm'},
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>👤</Text>
        </View>
        <Text style={styles.name}>John Doe</Text>
        <Text style={styles.email}>john.doe@example.com</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>My Measurements</Text>
        <View style={styles.measurementsGrid}>
          {measurements.map((item, index) => (
            <View key={index} style={styles.measurementCard}>
              <Text style={styles.measurementLabel}>{item.label}</Text>
              <Text style={styles.measurementValue}>{item.value}</Text>
              <Text style={styles.measurementUnit}>{item.unit}</Text>
            </View>
          ))}
        </View>
        <TouchableOpacity style={styles.updateButton}>
          <Text style={styles.updateButtonText}>Update Measurements</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Account Settings</Text>
        <TouchableOpacity style={styles.settingItem}>
          <Text style={styles.settingIcon}>👤</Text>
          <View style={styles.settingInfo}>
            <Text style={styles.settingTitle}>Edit Profile</Text>
            <Text style={styles.settingDesc}>Update personal information</Text>
          </View>
          <Text style={styles.settingArrow}>›</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingItem}>
          <Text style={styles.settingIcon}>📍</Text>
          <View style={styles.settingInfo}>
            <Text style={styles.settingTitle}>Addresses</Text>
            <Text style={styles.settingDesc}>Manage delivery addresses</Text>
          </View>
          <Text style={styles.settingArrow}>›</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.settingItem}>
          <Text style={styles.settingIcon}>💳</Text>
          <View style={styles.settingInfo}>
            <Text style={styles.settingTitle}>Payment Methods</Text>
            <Text style={styles.settingDesc}>Saved payment options</Text>
          </View>
          <Text style={styles.settingArrow}>›</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  header: {
    backgroundColor: '#667eea',
    padding: 30,
    alignItems: 'center',
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  avatarText: {
    fontSize: 40,
  },
  name: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 5,
  },
  email: {
    fontSize: 14,
    color: '#fff',
    opacity: 0.9,
  },
  section: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#495057',
    marginBottom: 15,
  },
  measurementsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 15,
  },
  measurementCard: {
    width: '48%',
    backgroundColor: '#f8f9fa',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 10,
  },
  measurementLabel: {
    fontSize: 12,
    color: '#6c757d',
    marginBottom: 5,
  },
  measurementValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#667eea',
  },
  measurementUnit: {
    fontSize: 14,
    color: '#6c757d',
  },
  updateButton: {
    backgroundColor: '#667eea',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  updateButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: 'bold',
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
  },
  settingIcon: {
    fontSize: 24,
    marginRight: 15,
  },
  settingInfo: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#495057',
    marginBottom: 3,
  },
  settingDesc: {
    fontSize: 12,
    color: '#6c757d',
  },
  settingArrow: {
    fontSize: 24,
    color: '#6c757d',
  },
});

export default ProfileScreen;
