import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  ScrollView,
  Alert,
} from 'react-native';

const MeasurementScreen = ({navigation}) => {
  const [photos, setPhotos] = useState({
    front: false,
    back: false,
    left: false,
    right: false,
  });
  const [height, setHeight] = useState('');
  const [weight, setWeight] = useState('');

  const uploadPhoto = view => {
    // Simulate photo upload
    setPhotos(prev => ({...prev, [view]: true}));
    Alert.alert('Success', `${view} photo uploaded!`);
  };

  const canProcess = () => {
    return (
      Object.values(photos).every(p => p) && height !== '' && weight !== ''
    );
  };

  const processImages = () => {
    if (!canProcess()) {
      Alert.alert('Error', 'Please upload all photos and enter your details');
      return;
    }

    Alert.alert(
      'Processing',
      'AI is calculating your measurements...',
      [
        {
          text: 'OK',
          onPress: () => {
            // Navigate to results or design studio
            setTimeout(() => {
              Alert.alert(
                'Success!',
                'Your measurements have been calculated',
                [{text: 'Continue', onPress: () => navigation.navigate('DesignStudio')}]
              );
            }, 1000);
          },
        },
      ]
    );
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Upload Photos</Text>
        <Text style={styles.sectionSubtitle}>
          Take 4 photos: front, back, left, and right views
        </Text>

        <View style={styles.uploadGrid}>
          {['front', 'back', 'left', 'right'].map(view => (
            <TouchableOpacity
              key={view}
              style={[
                styles.uploadBox,
                photos[view] && styles.uploadBoxActive,
              ]}
              onPress={() => uploadPhoto(view)}>
              <Text style={styles.uploadIcon}>
                {photos[view] ? '✅' : '📸'}
              </Text>
              <Text style={styles.uploadText}>
                {view.charAt(0).toUpperCase() + view.slice(1)}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Your Details</Text>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>Height (cm)</Text>
          <TextInput
            style={styles.input}
            placeholder="e.g., 175"
            keyboardType="numeric"
            value={height}
            onChangeText={setHeight}
          />
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.label}>Weight (kg)</Text>
          <TextInput
            style={styles.input}
            placeholder="e.g., 70"
            keyboardType="numeric"
            value={weight}
            onChangeText={setWeight}
          />
        </View>
      </View>

      <TouchableOpacity
        style={[styles.button, !canProcess() && styles.buttonDisabled]}
        onPress={processImages}
        disabled={!canProcess()}>
        <Text style={styles.buttonText}>Process Measurements</Text>
      </TouchableOpacity>

      <View style={styles.infoBox}>
        <Text style={styles.infoText}>
          💡 Tip: Stand 2 meters from camera in well-lit area
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
  section: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#495057',
    marginBottom: 5,
  },
  sectionSubtitle: {
    fontSize: 14,
    color: '#6c757d',
    marginBottom: 15,
  },
  uploadGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  uploadBox: {
    width: '48%',
    aspectRatio: 1,
    backgroundColor: '#f8f9fa',
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#dee2e6',
    borderStyle: 'dashed',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  uploadBoxActive: {
    borderColor: '#28a745',
    backgroundColor: '#d4edda',
    borderStyle: 'solid',
  },
  uploadIcon: {
    fontSize: 30,
    marginBottom: 5,
  },
  uploadText: {
    fontSize: 14,
    color: '#495057',
  },
  inputGroup: {
    marginBottom: 15,
  },
  label: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#495057',
    marginBottom: 5,
  },
  input: {
    borderWidth: 2,
    borderColor: '#dee2e6',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  button: {
    backgroundColor: '#667eea',
    padding: 15,
    margin: 20,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  infoBox: {
    margin: 20,
    marginTop: 0,
    padding: 15,
    backgroundColor: '#fff3cd',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#ffc107',
  },
  infoText: {
    fontSize: 14,
    color: '#856404',
  },
});

export default MeasurementScreen;
