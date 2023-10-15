import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'io.github.yey007.slider.app',
  appName: 'slider-app',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  }
};

export default config;
