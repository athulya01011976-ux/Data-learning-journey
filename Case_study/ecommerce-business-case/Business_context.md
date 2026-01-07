## Business Background (Client Perspective)

We are a 3-year-old e-commerce startup selling consumer lifestyle products (home essentials, electronics accessories, and personal care items).

- Operate in India

- Website + Android app

- Revenue driven mainly by paid marketing (Google, Meta) and repeat customers

- Recently scaled marketing spend but profitability is unstable

- Leadership wants “data-driven decisions” but isn’t clear what that means yet

## Current concerns:

- Growth feels slower despite higher ad spend

- Some products sell very well, others don’t move

- Customers complain about delivery delays occasionally

- Management meetings often end with “we need better insights”

## Data Available

You have access to the following tables (last 18 months of data):

### 1. orders

- order_id

- user_id

- order_date

- order_status (placed, shipped, delivered, cancelled, returned)

- total_amount

- payment_method

### 2.order_items

- order_id

- product_id

- quantity

- item_price

- discount_applied

### 3.products

- product_id

- category

- brand

- cost_price

- selling_price

### 4.users

- user_id

- signup_date

- city

- acquisition_channel (organic, google_ads, meta_ads, referral)

### 5.marketing_spend

- date

- channel

- spend_amount

- campaign_id

### 6.delivery

- order_id

- promised_days

- actual_delivery_days

## 5 Intentionally Vague Client Questions

These are exactly how leadership phrases them — unclear, high-level, and slightly confused:

1. “Are we actually growing properly, or does it just look like growth?”

2. “Marketing is costing us a lot — is it even worth it?”

3. “Which customers are good customers?”

4. “Some products feel profitable but I’m not sure — can you check?”

5. “Delivery issues keep coming up in reviews — is this really a big problem or just noise?”



