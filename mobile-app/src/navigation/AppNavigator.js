import React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {createStackNavigator} from '@react-navigation/stack';

// Placeholder screens
import HomeScreen from '../screens/HomeScreen';
import MeasurementScreen from '../screens/MeasurementScreen';
import DesignStudioScreen from '../screens/DesignStudioScreen';
import VirtualTryOnScreen from '../screens/VirtualTryOnScreen';
import OrdersScreen from '../screens/OrdersScreen';
import ProfileScreen from '../screens/ProfileScreen';

const Tab = createBottomTabNavigator();
const Stack = createStackNavigator();

// Home Stack Navigator
const HomeStack = () => {
  return (
    <Stack.Navigator>
      <Stack.Screen 
        name="Home" 
        component={HomeScreen}
        options={{title: 'Tiraz - طِرَاز'}}
      />
      <Stack.Screen 
        name="Measurement" 
        component={MeasurementScreen}
        options={{title: 'AI Measurement'}}
      />
      <Stack.Screen 
        name="DesignStudio" 
        component={DesignStudioScreen}
        options={{title: 'Design Studio'}}
      />
      <Stack.Screen 
        name="VirtualTryOn" 
        component={VirtualTryOnScreen}
        options={{title: 'Virtual Try-On'}}
      />
    </Stack.Navigator>
  );
};

// Main App Navigator
const AppNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#667eea',
        tabBarInactiveTintColor: '#6c757d',
      }}>
      <Tab.Screen 
        name="HomeTab" 
        component={HomeStack}
        options={{
          tabBarLabel: 'Home',
          tabBarIcon: () => '🏠',
        }}
      />
      <Tab.Screen 
        name="Orders" 
        component={OrdersScreen}
        options={{
          tabBarLabel: 'Orders',
          tabBarIcon: () => '📦',
          headerShown: true,
          title: 'My Orders',
        }}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profile',
          tabBarIcon: () => '👤',
          headerShown: true,
          title: 'Profile',
        }}
      />
    </Tab.Navigator>
  );
};

export default AppNavigator;
