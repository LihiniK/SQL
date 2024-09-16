# iPhones Sales Analysis

## Table of Contents
---

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning/ Preparation](#data-cleaning-preparation)
- [Exploratory Data Analysis](#exploratory-data-analysis)
- [Data Analysis](#data-analysis)
- [Results/ Findings](#results-findings)
- [Recommendations](#recommendations)
- [Limitations](#limitations)

### Project Overview
---

Apple iPhones are some of the top-selling smartphones globally. Even though there’s a lot of competition, with other brands offering the latest technology at half the price, iPhones still sell very well. This data analysis project aims to provide insights into the performance of iPhone sales. By analyzing various aspects of the sales data, we seek to identify trends, make data-driven recommendations, and gain a deeper understanding of the sales's performance.

![test1](https://github.com/user-attachments/assets/5ce70896-355a-451d-a4c6-76b67aa881bf)


### Data Sources

The primary dataset used for this analysis is the "apple_products.csv" file collected from Kaggle, which contains data about the sales of iPhones in India on Flipkart and detailed information about each product sale.

### Tools

- Python - Data Cleaning, Data Analysis, Creating reports

### Data Cleaning/ Preparation

In the initial data preparation phase, we performed the following tasks:

1. Data loading and inspection.
2. Handling missing values.
3. Data cleaning and formatting.

### Exploratory Data Analysis

EDA involved exploring the sales data to answer questions, such as:

- Which products are top sellers?
- What is the overall sales trend?
- What are the peak sales products?

### Data Analysis

the Python code is attached here.


![newplot (2)](https://github.com/user-attachments/assets/7bca90a3-c8ba-4601-8018-3068a24c9205)
![newplot (1)](https://github.com/user-attachments/assets/668eca19-a441-443b-b610-bfb73d2c1ac9)
![newplot](https://github.com/user-attachments/assets/c910ac15-343f-47ac-adc0-7b6cef01e05c)



### Results/ Findings

The analysis results are summarized as follows:
1. According to the available data, below are the top 5 most liked iPhones in India:
  - APPLE iPhone 11 Pro Max (Midnight Green, 64 GB)
  - APPLE iPhone 11 Pro Max (Space Grey, 64 GB)
  - APPLE iPhone 11 Pro Max (Midnight Green, 256 GB) 
  - APPLE iPhone 11 Pro Max (Gold, 64 GB)
  - APPLE iPhone 11 Pro Max (Gold, 256 GB)

2. The APPLE iPhone 8 Plus (Gold, 64 GB) has the most ratings and also leads in the highest number of reviews on Flipkart among the top-rated iPhones in India. There's a negative linear relationship between the sale price of iPhones and the number of ratings, indicating that iPhones with lower prices sell more in India. Additionally, there's a positive linear relationship between the discount percentage and the number of ratings, meaning iPhones with higher discounts tend to sell more on Flipkart.
3. There is a significant increase in ratings when the sale price of iPhones with the highest available RAM is reduced. However, for iPhones with 4 GB of RAM, the increase in ratings is only slight when prices drop. Meanwhile, iPhones with 2 GB of RAM show little to no increase in ratings, even with a price reduction.

### Recommendations

Based on the analysis, we recommend the following actions:

- Since there is a significant increase in ratings when iPhones with Lower available RAM have a reduced sale price, offering discounts on Low-RAM models like the iPhone 11 Pro Max could boost sales and customer engagement.
- Lower-priced iPhones, such as the iPhone 8 Plus, receive more ratings and reviews. Offering moderate discounts on popular mid-range models can attract more customers and drive up sales in India, where price sensitivity plays a crucial role.
- Reduce Focus on High-RAM Models: Since iPhones with 2 GB RAM show an increase in ratings with price reductions, it's more effective to prioritize marketing efforts and discounts on Lower-RAM models that demonstrate greater responsiveness to price drops.


### Limitations

No Limitations.

### References

1. [Kaggle](https://www.kaggle.com/datasets/komalkhetlani/apple-iphone-data)
2. [Stack Overflow](https://stack.com)


