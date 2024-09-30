DROP SCHEMA IF EXISTS pagarme CASCADE;

CREATE SCHEMA pagarme;

CREATE TABLE pagarme.client (
  id VARCHAR(255) NOT NULL,
  cpf VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  birth_date DATE,
  --
  PRIMARY KEY (id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE pagarme.payer (
  id VARCHAR(255) NOT NULL,
  client_id VARCHAR(255) NOT NULL,
  --
  PRIMARY KEY (id, client_id),
  FOREIGN KEY (client_id) REFERENCES pagarme.client(id),
  --
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE pagarme.payer_billing_address (
  id VARCHAR(255) NOT NULL,
  payer_id VARCHAR(255),
  street VARCHAR(255),
  number VARCHAR(255),
  neighborhood VARCHAR(255),
  city VARCHAR(255),
  state VARCHAR(255),
  country VARCHAR(255),
  zipcode VARCHAR(255),
  -- 
  PRIMARY KEY (id),
  --
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  --
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id)
);

CREATE TYPE pagarme.payer_billing_contact_type AS ENUM('EMAIL', 'PHONE');

CREATE TABLE pagarme.payer_billing_contact (
  id VARCHAR(255),
  payer_id VARCHAR(255) NOT NULL,
  contact_type pagarme.payer_billing_contact_type NOT NULL,
  contact VARCHAR(255) NOT NULL,
  -- 
  PRIMARY KEY (id),
  --
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- 
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id)
);

CREATE TYPE pagarme.payment_method AS ENUM('CREDIT_CARD', 'DEBIT_CARD');

CREATE TABLE pagarme.payer_payment_card (
  id VARCHAR(255),
  payer_id VARCHAR(255),
  card_method pagarme.payment_method NOT NULL,
  card_holder_name VARCHAR(255) NOT NULL,
  card_number VARCHAR(255) NOT NULL,
  card_expiration_date VARCHAR(4) NOT NULL,
  card_cvv VARCHAR(255) NOT NULL,
  --
  PRIMARY KEY (id, payer_id),
  --
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- 
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id)
);

CREATE TABLE pagarme.transaction (
  id VARCHAR(255),
  payer_id VARCHAR(255),
  payer_card_id VARCHAR(255),
  payer_billing_address_id VARCHAR(255),
  payer_billing_contact_id VARCHAR(255),
  amount INTEGER NOT NULL,
  description VARCHAR(255),
  -- 
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- 
  PRIMARY KEY (id),
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id),
  FOREIGN KEY (payer_card_id) REFERENCES pagarme.payer_payment_card(id),
  FOREIGN KEY (payer_billing_address_id) REFERENCES pagarme.payer_billing_address(id),
  FOREIGN KEY (payer_billing_contact_id) REFERENCES pagarme.payer_billing_contact(id)
);

CREATE TABLE pagarme.payee (
  id VARCHAR(255),
  client_id VARCHAR(255),
  --
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  --
  PRIMARY KEY (id, client_id),
  FOREIGN KEY (client_id) REFERENCES pagarme.client(id)
);

CREATE TYPE pagarme.payee_account_status AS ENUM(
  'PENDING',
  'APPROVED',
  'REJECTED',
  'INACTIVE',
  'BLOCKED'
);

CREATE TABLE pagarme.payee_account (
  id VARCHAR(255),
  payee_id VARCHAR(255),
  bank_unit VARCHAR(255) NOT NULL,
  agency VARCHAR(255) NOT NULL,
  account VARCHAR(255) NOT NULL,
  account_digit VARCHAR(255) NOT NULL,
  status pagarme.payee_account_status,
  -- 
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- 
  PRIMARY KEY (id, bank_unit),
  FOREIGN KEY (payee_id) REFERENCES pagarme.payee(id)
);

CREATE TABLE pagarme.payable (
  id VARCHAR(255),
  payee_id VARCHAR(255),
  transaction_id VARCHAR(255),
  status VARCHAR(255) NOT NULL,
  payment_date DATE NOT NULL,
  fee DECIMAL NOT NULL,
  -- 
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  -- 
  PRIMARY KEY (id),
  FOREIGN KEY (transaction_id) REFERENCES pagarme.transaction(id),
  FOREIGN KEY (payee_id) REFERENCES pagarme.payee(id)
);