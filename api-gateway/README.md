# API Gateway

Creating an API Gateway with its various endpoints, methods, and access policies by hand
is tedious and labor-intensive. Developers are helped significantly by using tools such as
SAM (Sserverless Application Model), AWS Cloud Development Kit (CDK), Hashicorp Terraform,
or Chalice.

Chalice is a python-based package that supports the creation of API Gateway endpoints, resources,
methods, and access policies, as well as the Lambda functions behind them.

The demo in this directory offers a simple example of a Chalice-derived API. Once you have installed
Chalice and other dependencies, this command will run the API locally:

```
chalice local
```

To deploy a working API:

```
chalice deploy
```
