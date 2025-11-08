import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
} from 'react-native';
import {Picker} from '@react-native-picker/picker';

const DesignStudioScreen = ({navigation}) => {
  const [category, setCategory] = useState('');
  const [fabric, setFabric] = useState('');
  const [collarStyle, setCollarStyle] = useState('classic');
  const [sleeveLength, setSleeveLength] = useState('full');

  const fabrics = [
    {id: 1, name: 'Premium Cotton', color: '#E8F4F8'},
    {id: 2, name: 'Linen Blend', color: '#F5E6D3'},
    {id: 3, name: 'Silk Touch', color: '#FFF8DC'},
    {id: 4, name: 'Twill Fabric', color: '#E0E0E0'},
  ];

  const previewDesign = () => {
    if (!category || !fabric) {
      Alert.alert('Error', 'Please select category and fabric');
      return;
    }
    navigation.navigate('VirtualTryOn');
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Select Category</Text>
        <View style={styles.categoryButtons}>
          <TouchableOpacity
            style={[
              styles.categoryButton,
              category === 'thobes' && styles.categoryButtonActive,
            ]}
            onPress={() => setCategory('thobes')}>
            <Text style={styles.categoryButtonText}>Men's Thobes</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[
              styles.categoryButton,
              category === 'shirts' && styles.categoryButtonActive,
            ]}
            onPress={() => setCategory('shirts')}>
            <Text style={styles.categoryButtonText}>Men's Shirts</Text>
          </TouchableOpacity>
        </View>
      </View>

      {category && (
        <>
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Choose Fabric</Text>
            <View style={styles.fabricGrid}>
              {fabrics.map(item => (
                <TouchableOpacity
                  key={item.id}
                  style={[
                    styles.fabricCard,
                    fabric === item.name && styles.fabricCardActive,
                  ]}
                  onPress={() => setFabric(item.name)}>
                  <View
                    style={[
                      styles.fabricSwatch,
                      {backgroundColor: item.color},
                    ]}
                  />
                  <Text style={styles.fabricName}>{item.name}</Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          <View style={styles.section}>
            <Text style={styles.sectionTitle}>Customization</Text>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Collar Style</Text>
              <View style={styles.pickerContainer}>
                <Picker
                  selectedValue={collarStyle}
                  onValueChange={setCollarStyle}
                  style={styles.picker}>
                  <Picker.Item label="Classic" value="classic" />
                  <Picker.Item label="Modern" value="modern" />
                  <Picker.Item label="Mandarin" value="mandarin" />
                </Picker>
              </View>
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>Sleeve Length</Text>
              <View style={styles.pickerContainer}>
                <Picker
                  selectedValue={sleeveLength}
                  onValueChange={setSleeveLength}
                  style={styles.picker}>
                  <Picker.Item label="Full Sleeve" value="full" />
                  <Picker.Item label="3/4 Sleeve" value="three-quarter" />
                  <Picker.Item label="Short Sleeve" value="short" />
                </Picker>
              </View>
            </View>
          </View>

          <TouchableOpacity style={styles.button} onPress={previewDesign}>
            <Text style={styles.buttonText}>Preview in 3D →</Text>
          </TouchableOpacity>
        </>
      )}
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
    marginBottom: 15,
  },
  categoryButtons: {
    flexDirection: 'row',
    gap: 10,
  },
  categoryButton: {
    flex: 1,
    padding: 15,
    backgroundColor: '#f8f9fa',
    borderRadius: 10,
    borderWidth: 2,
    borderColor: '#dee2e6',
    alignItems: 'center',
  },
  categoryButtonActive: {
    backgroundColor: '#e7f3ff',
    borderColor: '#667eea',
  },
  categoryButtonText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#495057',
  },
  fabricGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  fabricCard: {
    width: '48%',
    backgroundColor: '#f8f9fa',
    borderRadius: 10,
    borderWidth: 3,
    borderColor: 'transparent',
    marginBottom: 10,
    overflow: 'hidden',
  },
  fabricCardActive: {
    borderColor: '#667eea',
  },
  fabricSwatch: {
    height: 100,
    width: '100%',
  },
  fabricName: {
    padding: 10,
    fontSize: 12,
    textAlign: 'center',
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
  pickerContainer: {
    borderWidth: 2,
    borderColor: '#dee2e6',
    borderRadius: 8,
    overflow: 'hidden',
  },
  picker: {
    height: 50,
  },
  button: {
    backgroundColor: '#667eea',
    padding: 15,
    margin: 20,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default DesignStudioScreen;
