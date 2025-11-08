import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
} from 'react-native';

const VirtualTryOnScreen = ({navigation}) => {
  const [rotation, setRotation] = useState(0);

  const rotateAvatar = direction => {
    if (direction === 'left') {
      setRotation(prev => prev - 90);
    } else if (direction === 'right') {
      setRotation(prev => prev + 90);
    } else {
      setRotation(0);
    }
  };

  const placeOrder = () => {
    Alert.alert(
      'Order Placed!',
      'Your custom garment order has been placed successfully.\n\nOrder ID: #' +
        Math.floor(Math.random() * 90000 + 10000) +
        '\nExpected delivery: 5-7 business days',
      [
        {
          text: 'View Orders',
          onPress: () => navigation.navigate('Orders'),
        },
        {
          text: 'OK',
          onPress: () => navigation.navigate('Home'),
        },
      ],
    );
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.viewerContainer}>
        <View
          style={[
            styles.avatar,
            {transform: [{rotate: `${rotation}deg`}]},
          ]}>
          <Text style={styles.avatarText}>3D Model</Text>
          <Text style={styles.avatarSubtext}>Your Avatar</Text>
        </View>

        <View style={styles.rotationControls}>
          <TouchableOpacity
            style={styles.rotationButton}
            onPress={() => rotateAvatar('left')}>
            <Text style={styles.rotationButtonText}>←</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.rotationButton}
            onPress={() => rotateAvatar('reset')}>
            <Text style={styles.rotationButtonText}>⟲</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.rotationButton}
            onPress={() => rotateAvatar('right')}>
            <Text style={styles.rotationButtonText}>→</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Design Summary</Text>
        <View style={styles.summaryCard}>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Category:</Text>
            <Text style={styles.summaryValue}>Men's Thobes</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Fabric:</Text>
            <Text style={styles.summaryValue}>Premium Cotton</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Collar:</Text>
            <Text style={styles.summaryValue}>Classic</Text>
          </View>
          <View style={styles.summaryRow}>
            <Text style={styles.summaryLabel}>Sleeves:</Text>
            <Text style={styles.summaryValue}>Full Sleeve</Text>
          </View>
          <View style={[styles.summaryRow, styles.summaryTotal]}>
            <Text style={styles.summaryLabelBold}>Total:</Text>
            <Text style={styles.summaryValueBold}>$120</Text>
          </View>
        </View>
      </View>

      <TouchableOpacity style={styles.button} onPress={placeOrder}>
        <Text style={styles.buttonText}>Place Order - $120</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={[styles.button, styles.buttonSecondary]}
        onPress={() => navigation.navigate('Home')}>
        <Text style={styles.buttonText}>Save for Later</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  viewerContainer: {
    backgroundColor: '#f8f9fa',
    height: 400,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  avatar: {
    width: 150,
    height: 250,
    backgroundColor: '#667eea',
    borderRadius: 75,
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#fff',
  },
  avatarSubtext: {
    fontSize: 14,
    color: '#fff',
    marginTop: 5,
  },
  rotationControls: {
    position: 'absolute',
    bottom: 20,
    flexDirection: 'row',
    backgroundColor: 'rgba(255, 255, 255, 0.9)',
    borderRadius: 30,
    padding: 10,
    gap: 15,
  },
  rotationButton: {
    width: 40,
    height: 40,
    backgroundColor: '#667eea',
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  rotationButtonText: {
    fontSize: 20,
    color: '#fff',
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
  summaryCard: {
    backgroundColor: '#f8f9fa',
    borderRadius: 10,
    padding: 15,
  },
  summaryRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#dee2e6',
  },
  summaryTotal: {
    borderBottomWidth: 0,
    paddingTop: 15,
    marginTop: 10,
    borderTopWidth: 2,
    borderTopColor: '#495057',
  },
  summaryLabel: {
    fontSize: 14,
    color: '#6c757d',
  },
  summaryValue: {
    fontSize: 14,
    color: '#495057',
    fontWeight: '600',
  },
  summaryLabelBold: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#495057',
  },
  summaryValueBold: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#667eea',
  },
  button: {
    backgroundColor: '#667eea',
    padding: 15,
    marginHorizontal: 20,
    marginBottom: 10,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonSecondary: {
    backgroundColor: '#6c757d',
    marginBottom: 20,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default VirtualTryOnScreen;
