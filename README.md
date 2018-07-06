# Automated enterprise BI with SQL Data Warehouse and Azure Data Factory

This reference architecture shows how to perform incremental loading in an [ELT](https://docs.microsoft.com/azure/architecture/data-guide/relational-data/etl#extract-load-and-transform-elt) (extract-load-transform) pipeline. It uses Azure Data Factory to automate the ELT pipeline. The pipeline incrementally moves the latest OLTP data from an on-premises SQL Server database into SQL Data Warehouse. Transactional data is transformed into a tabular model for analysis.

![](https://docs.microsoft.com/azure/architecture/reference-architectures/data/images/enterprise-bi-sqldw-adf.png)

For deployment instructions and guidance about best practices, see the article [Automated enterprise BI with SQL Data Warehouse and Azure Data Factory](https://docs.microsoft.com/azure/architecture/reference-architectures/data/enterprise-bi-adf) on the Azure Architecture Center.

The deployment uses [Azure Building Blocks](https://github.com/mspnp/template-building-blocks/wiki) (azbb), a command line tool that simplifies deployment of Azure resources.