-- ==========================================
-- 1. SCHEMA CREATION (DDL)
-- ==========================================

CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL,
    budget_code VARCHAR(20) UNIQUE
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    salary DECIMAL(10, 2) CHECK (salary > 0),
    dept_id INT,
    CONSTRAINT fk_emp_dept FOREIGN KEY (dept_id)
        REFERENCES department (dept_id)
        ON DELETE SET NULL
);

CREATE TABLE project (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    budget DECIMAL(12, 2) CHECK (budget >= 0),
    dept_id INT NOT NULL,
    CONSTRAINT fk_proj_dept FOREIGN KEY (dept_id)
        REFERENCES department (dept_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_dates CHECK (end_date >= start_date)
);

CREATE TABLE project_assignment (
    assignment_id INT PRIMARY KEY,
    emp_id INT NOT NULL,
    proj_id INT NOT NULL,
    role VARCHAR(50) DEFAULT 'Contributor',
    hours_allocated DECIMAL(5, 2) CHECK (hours_allocated >= 0),
    CONSTRAINT fk_assign_emp FOREIGN KEY (emp_id)
        REFERENCES employee (emp_id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_proj FOREIGN KEY (proj_id)
        REFERENCES project (proj_id) ON DELETE CASCADE,
    CONSTRAINT uq_emp_proj UNIQUE (emp_id, proj_id)
);

CREATE TABLE payroll (
    pay_id INT PRIMARY KEY,
    emp_id INT NOT NULL,
    payment_date DATE NOT NULL,
    gross_pay DECIMAL(10, 2) CHECK (gross_pay > 0),
    tax_deduction DECIMAL(10, 2) CHECK (tax_deduction >= 0),
    net_pay DECIMAL(10, 2) GENERATED ALWAYS AS (gross_pay - tax_deduction) STORED,
    CONSTRAINT fk_pay_emp FOREIGN KEY (emp_id)
        REFERENCES employee (emp_id) ON DELETE CASCADE
);

CREATE INDEX idx_emp_dept ON employee(dept_id);
CREATE INDEX idx_proj_dept ON project(dept_id);
CREATE INDEX idx_pay_emp_date ON payroll(emp_id, payment_date);

-- ==========================================
-- 2. DATA INGESTION (DML)
-- ==========================================

INSERT INTO department VALUES
(101, 'Engineering', 'Building A Fl 3', 'ENG-B2026'),
(102, 'Data Analytics', 'Building B Fl 1', 'DAT-B2026'),
(103, 'Human Resources', 'Building A Fl 1', 'HR-B2026');

INSERT INTO employee VALUES
(1001, 'Alice', 'Smith', 'alice.smith@corp.com', '555-0192', '2022-03-15', 'Senior Engineer', 95000.00, 101),
(1002, 'Bob', 'Jones', 'bob.jones@corp.com', '555-0193', '2021-06-01', 'Lead Analyst', 88000.00, 102),
(1003, 'Carol', 'White', 'carol.white@corp.com', '555-0194', '2023-01-10', 'HR Specialist', 62000.00, 103),
(1004, 'David', 'Brown', 'david.brown@corp.com', '555-0195', '2020-11-20', 'Software Architect', 120000.00, 101);

INSERT INTO project VALUES
(501, 'Cloud Migration', '2026-01-01', '2026-12-31', 250000.00, 101),
(502, 'BI Dashboard Development', '2026-02-15', '2026-08-30', 75000.00, 102),
(503, 'HR Portal Upgrade', '2026-04-01', '2026-09-30', 45000.00, 103);

INSERT INTO project_assignment VALUES
(1, 1001, 501, 'Lead Developer', 160.0),
(2, 1004, 501, 'System Architect', 120.0),
(3, 1002, 502, 'Data Modeler', 140.0);

INSERT INTO payroll (pay_id, emp_id, payment_date, gross_pay, tax_deduction) VALUES
(9001, 1001, '2026-03-31', 7916.67, 1583.33),
(9002, 1002, '2026-03-31', 7333.33, 1466.67),
(9003, 1004, '2026-03-31', 10000.00, 2200.00);

-- ==========================================
-- 3. ANALYTICAL QUERIES
-- ==========================================

-- Departmental Salary Expenditure Summary
SELECT 
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    COALESCE(SUM(e.salary), 0) AS total_payroll,
    COALESCE(AVG(e.salary), 0) AS avg_salary
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY total_payroll DESC;

-- Employee Above-Average Salary Subquery
SELECT 
    e.emp_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.dept_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
WHERE e.salary > (
    SELECT AVG(e_sub.salary)
    FROM employee e_sub
    WHERE e_sub.dept_id = e.dept_id
);

-- Cross-Department Salary Ranking
SELECT 
    emp_id,
    first_name,
    last_name,
    dept_id,
    salary,
    DENSE_RANK() OVER (
        PARTITION BY dept_id 
        ORDER BY salary DESC
    ) AS dept_salary_rank
FROM employee;