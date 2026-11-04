# student-managment-project 
# Enterprise Management Database System Design & Implementation

**Course Code:** CS304 - Database Management Systems  
**Academic Session:** 2026–2027  
**Department:** Department of Computer Science & Information Systems  
**Faculty:** Faculty of Computing and Informatics  

---

## 📌 Project Overview
Modern organizational efficiency relies heavily on robust, scalable, and normalized relational database management systems (RDBMS). This project presents the comprehensive design, architectural modeling, and technical implementation of an **Enterprise Management Database System** engineered to support transactional processing and data-driven analytical reporting.

The system models critical enterprise operations including department hierarchies, employee assignments, project allocations, dynamic budget management, and payroll execution.

---

## 🎯 Key Objectives
* **Conceptual Architecture:** Construct an Entity-Relationship Diagram (ERD) mapping core entity sets, relationships, and cardinalities.
* **Logical Normalization:** Analyze and decompose tables into **Third Normal Form (3NF)** to eliminate redundancy and update/insertion/deletion anomalies.
* **Physical Implementation:** Execute clean SQL DDL statements with integrity constraints, check domain conditions, and foreign key cascades.
* **Analytical Intelligence:** Develop analytical SQL queries featuring multi-table joins, subqueries, aggregation metrics, and window functions.
* **Security & Governance:** Implement Role-Based Access Control (RBAC) and backup/disaster recovery strategies.

---

## 🛠 System Requirements & Specifications

### Hardware Allocation
* **CPU:** 4 vCPU
* **RAM:** 16 GB RAM
* **Storage:** NVMe SSD

### Software Stack
* **Database Engine:** PostgreSQL 15 / MySQL 8.0
* **Data Modeling:** pgModeler / Lucidchart
* **Query Client:** pgAdmin 4 / MySQL Workbench

---

## 🗄 Database Design & Schema

The database consists of **5 main tables**:

| Table Name | Description | Primary Key | Foreign Keys |
| :--- | :--- | :--- | :--- |
| **`department`** | Stores structural business divisions | `dept_id` | - |
| **`employee`** | Manages staff personal & role details | `emp_id` | `dept_id` → `department(dept_id)` |
| **`project`** | Tracks company projects & budget allocations | `proj_id` | `dept_id` → `department(dept_id)` |
| **`project_assignment`** | Associative table for employee project hours | `assignment_id` | `emp_id`, `proj_id` |
| **`payroll`** | Financial log tracking employee salary disbursements | `pay_id` | `emp_id` → `employee(emp_id)` |

---

## 📐 Normalization Steps (UNF to 3NF)

1. **1NF (First Normal Form):** Enforced scalar/atomic values for all attributes, removed repeating groups (`phone_numbers`, `proj_ids`), and established primary keys.
2. **2NF (Second Normal Form):** Decomposed `EMP_PROJECT_1NF` to eliminate partial functional dependencies, separating `PROJECT` entity attributes from assignment hours.
3. **3NF (Third Normal Form):** Removed transitive dependencies where `emp_id -> dept_id` and `dept_id -> {dept_name, location}` by isolating department details into a dedicated `DEPARTMENT` table.

---

## 💻 SQL Database Implementation (DDL)

```sql
-- 1. Create Department Table
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL,
    budget_code VARCHAR(20) UNIQUE
);

-- 2. Create Employee Table
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

-- 3. Create Project Table
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

-- 4. Create Project Assignment Table
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

-- 5. Create Payroll Table
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

-- Performance Optimization Indexes
CREATE INDEX idx_emp_dept ON employee(dept_id);
CREATE INDEX idx_proj_dept ON project(dept_id);
CREATE INDEX idx_pay_emp_date ON payroll(emp_id, payment_date);