-- ============================================================
-- SUBSCRIPTION BILLING SYSTEM - FULL SCHEMA (20 TABLES)
-- ============================================================

DROP DATABASE IF EXISTS subscription_billing_system;
CREATE DATABASE subscription_billing_system;
USE subscription_billing_system;

-- ------------------------------------------------------------
-- 1. departments
-- ------------------------------------------------------------
CREATE TABLE departments (
    department_id   INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE,
    created_date    DATE NOT NULL
);

-- ------------------------------------------------------------
-- 2. employees
-- ------------------------------------------------------------
CREATE TABLE employees (
    employee_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(15)  NOT NULL UNIQUE,
    department_id INT NOT NULL,
    role          VARCHAR(50) NOT NULL,
    hire_date     DATE NOT NULL,
    status        ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_emp_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 3. customers
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(15)  NOT NULL UNIQUE,
    city          VARCHAR(50)  NOT NULL,
    state         VARCHAR(50)  NOT NULL,
    country       VARCHAR(50)  NOT NULL DEFAULT 'India',
    signup_date   DATE NOT NULL,
    status        ENUM('Active','Inactive','Suspended') NOT NULL DEFAULT 'Active'
);

-- ------------------------------------------------------------
-- 4. addresses
-- ------------------------------------------------------------
CREATE TABLE addresses (
    address_id    INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    address_line  VARCHAR(150) NOT NULL,
    city          VARCHAR(50)  NOT NULL,
    state         VARCHAR(50)  NOT NULL,
    pincode       VARCHAR(10)  NOT NULL,
    address_type  ENUM('Billing','Shipping') NOT NULL DEFAULT 'Billing',
    is_default    BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_addr_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 5. payment_methods
-- ------------------------------------------------------------
CREATE TABLE payment_methods (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT NOT NULL,
    method_type       ENUM('Credit Card','Debit Card','UPI','Net Banking','Wallet') NOT NULL,
    provider          VARCHAR(50) NOT NULL,
    masked_number     VARCHAR(30) NOT NULL,
    is_default        BOOLEAN NOT NULL DEFAULT TRUE,
    added_date        DATE NOT NULL,
    CONSTRAINT fk_pm_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 6. plans
-- ------------------------------------------------------------
CREATE TABLE plans (
    plan_id        INT AUTO_INCREMENT PRIMARY KEY,
    plan_name      VARCHAR(50)  NOT NULL UNIQUE,
    description    VARCHAR(255),
    price          DECIMAL(10,2) NOT NULL,
    billing_cycle  ENUM('Monthly','Quarterly','Yearly') NOT NULL,
    duration_days  INT NOT NULL,
    status         ENUM('Active','Discontinued') NOT NULL DEFAULT 'Active',
    CONSTRAINT chk_plan_price CHECK (price > 0),
    CONSTRAINT chk_plan_duration CHECK (duration_days > 0)
);

-- ------------------------------------------------------------
-- 7. features
-- ------------------------------------------------------------
CREATE TABLE features (
    feature_id   INT AUTO_INCREMENT PRIMARY KEY,
    feature_name VARCHAR(100) NOT NULL UNIQUE,
    description  VARCHAR(255)
);

-- ------------------------------------------------------------
-- 8. plan_features (junction: plans <-> features)
-- ------------------------------------------------------------
CREATE TABLE plan_features (
    plan_feature_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_id         INT NOT NULL,
    feature_id      INT NOT NULL,
    CONSTRAINT fk_pf_plan FOREIGN KEY (plan_id)
        REFERENCES plans(plan_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pf_feature FOREIGN KEY (feature_id)
        REFERENCES features(feature_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_plan_feature UNIQUE (plan_id, feature_id)
);

-- ------------------------------------------------------------
-- 9. coupons
-- ------------------------------------------------------------
CREATE TABLE coupons (
    coupon_id         INT AUTO_INCREMENT PRIMARY KEY,
    code              VARCHAR(20) NOT NULL UNIQUE,
    discount_percent  DECIMAL(5,2) NOT NULL,
    valid_from        DATE NOT NULL,
    valid_to          DATE NOT NULL,
    status            ENUM('Active','Expired') NOT NULL DEFAULT 'Active',
    CONSTRAINT chk_coupon_discount CHECK (discount_percent BETWEEN 0 AND 100),
    CONSTRAINT chk_coupon_dates CHECK (valid_to > valid_from)
);

-- ------------------------------------------------------------
-- 10. subscriptions
-- ------------------------------------------------------------
CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    plan_id         INT NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    auto_renew      BOOLEAN NOT NULL DEFAULT TRUE,
    status          ENUM('Active','Expired','Cancelled') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_sub_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id)
        REFERENCES plans(plan_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_sub_dates CHECK (end_date > start_date)
);

-- ------------------------------------------------------------
-- 11. subscription_coupons (junction: subscriptions <-> coupons)
-- ------------------------------------------------------------
CREATE TABLE subscription_coupons (
    subscription_coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id        INT NOT NULL,
    coupon_id              INT NOT NULL,
    applied_date           DATE NOT NULL,
    CONSTRAINT fk_sc_subscription FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sc_coupon FOREIGN KEY (coupon_id)
        REFERENCES coupons(coupon_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_sub_coupon UNIQUE (subscription_id, coupon_id)
);

-- ------------------------------------------------------------
-- 12. payments
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id        INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id   INT NOT NULL,
    payment_method_id INT NOT NULL,
    amount            DECIMAL(10,2) NOT NULL,
    payment_date      DATE NOT NULL,
    payment_status    ENUM('Success','Failed','Pending','Refunded') NOT NULL DEFAULT 'Success',
    CONSTRAINT fk_pay_subscription FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pay_method FOREIGN KEY (payment_method_id)
        REFERENCES payment_methods(payment_method_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_pay_amount CHECK (amount >= 0)
);

-- ------------------------------------------------------------
-- 13. invoices
-- ------------------------------------------------------------
CREATE TABLE invoices (
    invoice_id      INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,
    invoice_date    DATE NOT NULL,
    due_date        DATE NOT NULL,
    amount          DECIMAL(10,2) NOT NULL,
    status          ENUM('Paid','Unpaid','Overdue') NOT NULL DEFAULT 'Unpaid',
    CONSTRAINT fk_inv_subscription FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_inv_dates CHECK (due_date >= invoice_date)
);

-- ------------------------------------------------------------
-- 14. invoice_items
-- ------------------------------------------------------------
CREATE TABLE invoice_items (
    invoice_item_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id      INT NOT NULL,
    description     VARCHAR(150) NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    unit_price      DECIMAL(10,2) NOT NULL,
    line_total      DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_ii_invoice FOREIGN KEY (invoice_id)
        REFERENCES invoices(invoice_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_ii_qty CHECK (quantity > 0),
    CONSTRAINT chk_ii_price CHECK (unit_price >= 0)
);

-- ------------------------------------------------------------
-- 15. refunds
-- ------------------------------------------------------------
CREATE TABLE refunds (
    refund_id     INT AUTO_INCREMENT PRIMARY KEY,
    payment_id    INT NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    refund_date   DATE NOT NULL,
    reason        VARCHAR(150) NOT NULL,
    status        ENUM('Requested','Processed','Rejected') NOT NULL DEFAULT 'Requested',
    CONSTRAINT fk_ref_payment FOREIGN KEY (payment_id)
        REFERENCES payments(payment_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_refund_amount CHECK (refund_amount >= 0)
);

-- ------------------------------------------------------------
-- 16. renewals
-- ------------------------------------------------------------
CREATE TABLE renewals (
    renewal_id      INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,
    renewal_date    DATE NOT NULL,
    old_end_date    DATE NOT NULL,
    new_end_date    DATE NOT NULL,
    status          ENUM('Success','Failed') NOT NULL DEFAULT 'Success',
    CONSTRAINT fk_ren_subscription FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_ren_dates CHECK (new_end_date > old_end_date)
);

-- ------------------------------------------------------------
-- 17. cancellations
-- ------------------------------------------------------------
CREATE TABLE cancellations (
    cancellation_id   INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id   INT NOT NULL UNIQUE,
    cancellation_date DATE NOT NULL,
    reason            VARCHAR(150) NOT NULL,
    refund_issued     BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_can_subscription FOREIGN KEY (subscription_id)
        REFERENCES subscriptions(subscription_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 18. support_tickets
-- ------------------------------------------------------------
CREATE TABLE support_tickets (
    ticket_id            INT AUTO_INCREMENT PRIMARY KEY,
    customer_id          INT NOT NULL,
    assigned_employee_id INT NOT NULL,
    subject              VARCHAR(150) NOT NULL,
    issue_type           ENUM('Billing','Technical','Account','General') NOT NULL,
    status               ENUM('Open','In Progress','Resolved','Closed') NOT NULL DEFAULT 'Open',
    created_date         DATE NOT NULL,
    resolved_date         DATE NULL,
    CONSTRAINT fk_tkt_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tkt_employee FOREIGN KEY (assigned_employee_id)
        REFERENCES employees(employee_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_tkt_dates CHECK (resolved_date IS NULL OR resolved_date >= created_date)
);

-- ------------------------------------------------------------
-- 19. notifications
-- ------------------------------------------------------------
CREATE TABLE notifications (
    notification_id   INT AUTO_INCREMENT PRIMARY KEY,
    customer_id       INT NOT NULL,
    notification_type ENUM('Renewal Reminder','Payment Success','Payment Failed','Offer','System') NOT NULL,
    message           VARCHAR(255) NOT NULL,
    sent_date         DATE NOT NULL,
    is_read           BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_notif_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- 20. audit_logs
-- ------------------------------------------------------------
CREATE TABLE audit_logs (
    log_id       INT AUTO_INCREMENT PRIMARY KEY,
    table_name   VARCHAR(50) NOT NULL,
    record_id    INT NOT NULL,
    action_type  ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    changed_by   INT NOT NULL,
    change_date  DATETIME NOT NULL,
    old_value    VARCHAR(255),
    new_value    VARCHAR(255),
    CONSTRAINT fk_log_employee FOREIGN KEY (changed_by)
        REFERENCES employees(employee_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
