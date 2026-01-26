#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib/core';
import { ServiceStack } from '../lib/serviceStack';

const app = new cdk.App();

new ServiceStack(app, 'PhantomServiceStack', {
  env: { 
    account: '631253087051', 
    region: 'us-east-1' 
  },
});
