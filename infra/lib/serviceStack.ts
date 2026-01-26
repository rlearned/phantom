import * as cdk from 'aws-cdk-lib';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as cognito from 'aws-cdk-lib/aws-cognito';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as logs from 'aws-cdk-lib/aws-logs';
import { Construct } from 'constructs';
import * as path from 'path';

export class ServiceStack extends cdk.Stack {
  public readonly appTable: dynamodb.Table;
  public readonly cacheTable: dynamodb.Table;
  public readonly userPool: cognito.UserPool;
  public readonly userPoolClient: cognito.UserPoolClient;
  public readonly apiFunction: lambda.Function;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    this.appTable = new dynamodb.Table(this, 'AppTable', {
      tableName: 'phantom-app',
      partitionKey: {
        name: 'pk',
        type: dynamodb.AttributeType.STRING,
      },
      sortKey: {
        name: 'sk',
        type: dynamodb.AttributeType.STRING,
      },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    this.cacheTable = new dynamodb.Table(this, 'CacheTable', {
      tableName: 'phantom-cache',
      partitionKey: {
        name: 'pk',
        type: dynamodb.AttributeType.STRING,
      },
      sortKey: {
        name: 'sk',
        type: dynamodb.AttributeType.STRING,
      },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      timeToLiveAttribute: 'expiresAt',
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    new cdk.CfnOutput(this, 'AppTableName', {
      value: this.appTable.tableName,
      description: 'DynamoDB table for application data',
    });

    new cdk.CfnOutput(this, 'CacheTableName', {
      value: this.cacheTable.tableName,
      description: 'DynamoDB table for cached external API data',
    });

    this.userPool = new cognito.UserPool(this, 'UserPool', {
      userPoolName: 'phantom-users',
      signInAliases: {
        email: true,
      },
      autoVerify: {
        email: true,
      },
      mfa: cognito.Mfa.OPTIONAL,
      standardAttributes: {
        email: {
          required: true,
          mutable: true,
        },
      },
      customAttributes: {
        preferredUsername: new cognito.StringAttribute({ mutable: true }),
      },
      passwordPolicy: {
        minLength: 8,
        requireLowercase: true,
        requireUppercase: true,
        requireDigits: true,
        requireSymbols: false,
      },
      accountRecovery: cognito.AccountRecovery.EMAIL_ONLY,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    this.userPoolClient = new cognito.UserPoolClient(this, 'UserPoolClient', {
      userPool: this.userPool,
      authFlows: {
        userPassword: true,
        userSrp: true,
      },
      generateSecret: false,
      preventUserExistenceErrors: true,
    });

    new cdk.CfnOutput(this, 'UserPoolId', {
      value: this.userPool.userPoolId,
      description: 'Cognito User Pool ID',
    });

    new cdk.CfnOutput(this, 'UserPoolClientId', {
      value: this.userPoolClient.userPoolClientId,
      description: 'Cognito User Pool Client ID',
    });

    this.apiFunction = new lambda.Function(this, 'ApiFunction', {
      functionName: 'phantom-lambda',
      runtime: lambda.Runtime.JAVA_17,
      architecture: lambda.Architecture.X86_64,
      handler: 'com.phantom.handler.ApiHandler::handleRequest',
      code: lambda.Code.fromAsset(path.join(__dirname, '../../service/build/distributions/phantom-lambda.zip')),
      memorySize: 512,
      timeout: cdk.Duration.seconds(30),
      environment: {
        APP_TABLE_NAME: this.appTable.tableName,
        CACHE_TABLE_NAME: this.cacheTable.tableName,
      },
      logRetention: logs.RetentionDays.TWO_WEEKS,
    });

    this.appTable.grantReadWriteData(this.apiFunction);
    this.cacheTable.grantReadWriteData(this.apiFunction);

    new cdk.CfnOutput(this, 'ApiLambdaArn', {
      value: this.apiFunction.functionArn,
      description: 'Lambda function ARN',
    });
  }
}
