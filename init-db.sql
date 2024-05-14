DROP SCHEMA IF EXISTS pagarme CASCADE;

CREATE SCHEMA pagarme;

CREATE TABLE pagarme.client (
  id VARCHAR(255) NOT NULL,
  cpf VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  birth_date DATE NOT NULL,
  --
  PRIMARY KEY (id, cpf),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE pagarme.payer (
  id VARCHAR(255) NOT NULL,
  client_id VARCHAR(255) NOT NULL,
  --
  PRIMARY KEY (id, client_id),
  FOREIGN KEY (client_id) REFERENCES pagarme.client(id),
  --
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE pagarme.payer_billing_address (
  id VARCHAR(255) PRIMARY KEY,
  payer_id VARCHAR(255) NOT NULL,
  street VARCHAR(255) NOT NULL,
  number VARCHAR(255) NOT NULL,
  neighborhood VARCHAR(255) NOT NULL,
  city VARCHAR(255) NOT NULL,
  state VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL,
  zipcode VARCHAR(255) NOT NULL,
  -- 
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  --
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id)
);

CREATE TYPE pagarme.payer_billing_contact_type AS ENUM('EMAIL', 'PHONE');

CREATE TABLE pagarme.payer_billing_contact (
  id VARCHAR(255) PRIMARY KEY,
  payer_id VARCHAR(255) NOT NULL,
  contact_type pagarme.payer_billing_contact_type NOT NULL,
  contact VARCHAR(255) NOT NULL,
  -- 
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  -- 
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id)
);

CREATE TYPE pagarme.payment_method AS ENUM('CREDIT_CARD', 'DEBIT_CARD');

CREATE TABLE pagarme.payer_payment_card (
  id VARCHAR(255) PRIMARY KEY,
  payer_id VARCHAR(255) NOT NULL,
  card_method pagarme.payment_method NOT NULL,
  card_holder_name VARCHAR(255) NOT NULL,
  card_number VARCHAR(255) NOT NULL,
  card_expiration_date VARCHAR(4) NOT NULL,
  card_cvv VARCHAR(255) NOT NULL,
  -- 
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  -- 
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id)
);

CREATE TABLE pagarme.transaction (
  id VARCHAR(255) NOT NULL,
  payer_id VARCHAR(255) NOT NULL,
  payer_card_id VARCHAR(255) NOT NULL,
  payer_billing_address_id VARCHAR(255) NOT NULL,
  payer_billing_contact_id VARCHAR(255) NOT NULL,
  amount INTEGER NOT NULL,
  description VARCHAR(255),
  -- 
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  -- 
  PRIMARY KEY (id),
  FOREIGN KEY (payer_id) REFERENCES pagarme.payer(id),
  FOREIGN KEY (payer_card_id) REFERENCES pagarme.payer_payment_card(id),
  FOREIGN KEY (payer_billing_address_id) REFERENCES pagarme.payer_billing_address(id),
  FOREIGN KEY (payer_billing_contact_id) REFERENCES pagarme.payer_billing_contact(id)
);

CREATE TABLE pagarme.payee (
  id VARCHAR(255) NOT NULL,
  client_id VARCHAR(255) NOT NULL,
  --
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
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
  id VARCHAR(255) NOT NULL,
  payee_id VARCHAR(255) NOT NULL,
  bank_unit VARCHAR(255) NOT NULL,
  agency VARCHAR(255) NOT NULL,
  account VARCHAR(255) NOT NULL,
  account_digit VARCHAR(255) NOT NULL,
  status pagarme.payee_account_status NOT NULL,
  -- 
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  -- 
  PRIMARY KEY (id, bank_unit),
  FOREIGN KEY (payee_id) REFERENCES pagarme.payee(id)
);

CREATE TABLE pagarme.payable (
  id VARCHAR(255) NOT NULL,
  payee_id VARCHAR(255) NOT NULL,
  transaction_id VARCHAR(255) NOT NULL,
  status VARCHAR(255) NOT NULL,
  payment_date DATE NOT NULL,
  fee DECIMAL NOT NULL,
  -- 
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  -- 
  PRIMARY KEY (id),
  FOREIGN KEY (transaction_id) REFERENCES pagarme.transaction(id),
  FOREIGN KEY (payee_id) REFERENCES pagarme.payee(id)
);