import React from 'react';
import {View, Text, StyleSheet, ScrollView} from 'react-native';

const OrdersScreen = () => {
  const currentOrders = [
    {
      id: '12345',
      item: 'Navy Blue Thobe',
      status: 'In Progress',
      delivery: '5-7 days',
    },
  ];

  const pastOrders = [
    {
      id: '12344',
      item: 'White Classic Shirt',
      status: 'Completed',
      delivery: 'Delivered: Oct 15, 2024',
    },
    {
      id: '12343',
      item: 'Grey Modern Thobe',
      status: 'Completed',
      delivery: 'Delivered: Sep 28, 2024',
    },
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Current Orders</Text>
        {currentOrders.map(order => (
          <View key={order.id} style={styles.orderCard}>
            <View style={styles.orderHeader}>
              <Text style={styles.orderId}>Order #{order.id}</Text>
              <View style={[styles.badge, styles.badgeWarning]}>
                <Text style={styles.badgeText}>{order.status}</Text>
              </View>
            </View>
            <Text style={styles.orderItem}>{order.item}</Text>
            <Text style={styles.orderDelivery}>{order.delivery}</Text>
          </View>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Past Orders</Text>
        {pastOrders.map(order => (
          <View key={order.id} style={styles.orderCard}>
            <View style={styles.orderHeader}>
              <Text style={styles.orderId}>Order #{order.id}</Text>
              <View style={[styles.badge, styles.badgeSuccess]}>
                <Text style={styles.badgeText}>{order.status}</Text>
              </View>
            </View>
            <Text style={styles.orderItem}>{order.item}</Text>
            <Text style={styles.orderDelivery}>{order.delivery}</Text>
          </View>
        ))}
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
    marginBottom: 15,
  },
  orderCard: {
    backgroundColor: '#f8f9fa',
    borderRadius: 10,
    padding: 15,
    marginBottom: 15,
  },
  orderHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  orderId: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#495057',
  },
  badge: {
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 15,
  },
  badgeWarning: {
    backgroundColor: '#fff3cd',
  },
  badgeSuccess: {
    backgroundColor: '#d4edda',
  },
  badgeText: {
    fontSize: 12,
    fontWeight: 'bold',
  },
  orderItem: {
    fontSize: 14,
    color: '#495057',
    marginBottom: 5,
  },
  orderDelivery: {
    fontSize: 12,
    color: '#6c757d',
  },
});

export default OrdersScreen;
