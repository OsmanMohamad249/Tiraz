import React from 'react';
import {View, Text, StyleSheet, TouchableOpacity, ScrollView} from 'react-native';

const HomeScreen = ({navigation}) => {
  const features = [
    {
      id: 1,
      title: 'AI Measurement',
      icon: '📐',
      description: 'Get accurate measurements using AI',
      screen: 'Measurement',
    },
    {
      id: 2,
      title: 'Design Studio',
      icon: '✂️',
      description: 'Create your perfect garment',
      screen: 'DesignStudio',
    },
    {
      id: 3,
      title: 'Virtual Try-On',
      icon: '👔',
      description: 'See how it looks on you',
      screen: 'VirtualTryOn',
    },
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Welcome to Tiraz</Text>
        <Text style={styles.subtitle}>AI-Powered Custom Tailoring</Text>
      </View>

      <View style={styles.featuresContainer}>
        {features.map(feature => (
          <TouchableOpacity
            key={feature.id}
            style={styles.featureCard}
            onPress={() => navigation.navigate(feature.screen)}>
            <Text style={styles.featureIcon}>{feature.icon}</Text>
            <Text style={styles.featureTitle}>{feature.title}</Text>
            <Text style={styles.featureDescription}>{feature.description}</Text>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.infoBox}>
        <Text style={styles.infoText}>
          🎉 This is the Tiraz MVP Application
        </Text>
        <Text style={styles.infoSubtext}>
          Start by getting your AI measurements, then design your perfect
          custom garment!
        </Text>
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
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 16,
    color: '#fff',
    opacity: 0.9,
  },
  featuresContainer: {
    padding: 20,
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  featureCard: {
    width: '48%',
    backgroundColor: '#f8f9fa',
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
    alignItems: 'center',
    elevation: 2,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  featureIcon: {
    fontSize: 40,
    marginBottom: 10,
  },
  featureTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#495057',
    marginBottom: 5,
    textAlign: 'center',
  },
  featureDescription: {
    fontSize: 12,
    color: '#6c757d',
    textAlign: 'center',
  },
  infoBox: {
    margin: 20,
    padding: 20,
    backgroundColor: '#e7f3ff',
    borderRadius: 10,
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
  },
  infoText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#0d47a1',
    marginBottom: 8,
  },
  infoSubtext: {
    fontSize: 14,
    color: '#0d47a1',
    lineHeight: 20,
  },
});

export default HomeScreen;
