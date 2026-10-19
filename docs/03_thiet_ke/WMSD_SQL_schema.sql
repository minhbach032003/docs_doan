-- WMSD relational analysis/reference DDL, 2026-10-18. NOT a production schema.
-- Runtime persistence remains MongoDB (NoSQL), per Report 3 and the system design.
-- PostgreSQL syntax is used only to make the proposed relational model executable for review.
-- Schema only: posting/approval services and authorization are NOT implemented here.
-- Read the VI/EN proposal for cross-row rules and transaction boundaries.
-- Self-contained PostgreSQL reference DDL for design review only; never run as the MongoDB runtime schema.
BEGIN;
CREATE SCHEMA wmsd;
SET search_path TO wmsd, public;

CREATE TABLE app_user (
 user_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 username varchar(100) NOT NULL UNIQUE,
 display_name varchar(160) NOT NULL,
 credential_hash varchar(255) NOT NULL,
 active boolean NOT NULL DEFAULT true
);
CREATE TABLE app_role (role_code varchar(30) PRIMARY KEY);
INSERT INTO app_role VALUES ('OWNER'),('SALES'),('WAREHOUSE'),('ACCOUNTANT'),('ADMIN');
CREATE TABLE user_role (
 user_id bigint REFERENCES app_user, role_code varchar(30) REFERENCES app_role,
 PRIMARY KEY(user_id, role_code)
);
CREATE TABLE permission (permission_code varchar(80) PRIMARY KEY);
CREATE TABLE role_permission (
 role_code varchar(30) REFERENCES app_role, permission_code varchar(80) REFERENCES permission,
 PRIMARY KEY(role_code, permission_code)
);
CREATE TABLE warehouse (
 warehouse_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 code varchar(30) NOT NULL UNIQUE, name varchar(160) NOT NULL,
 address varchar(500), active boolean NOT NULL DEFAULT true
);
CREATE TABLE user_warehouse (
 user_id bigint REFERENCES app_user, warehouse_id bigint REFERENCES warehouse,
 PRIMARY KEY(user_id, warehouse_id)
);
CREATE TABLE location (
 location_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 code varchar(50) NOT NULL,
 location_kind varchar(20) NOT NULL CHECK(location_kind IN ('RECEIVING','STORAGE','STAGING','QUARANTINE','CUSTODY')),
 allocatable boolean NOT NULL DEFAULT false,
 active boolean NOT NULL DEFAULT true,
 UNIQUE(warehouse_id, code), UNIQUE(location_id, warehouse_id),
 CHECK(NOT allocatable OR location_kind = 'STORAGE')
);
CREATE TABLE party (
 party_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 code varchar(40) NOT NULL UNIQUE, name varchar(200) NOT NULL,
 party_kind varchar(12) NOT NULL CHECK(party_kind IN ('STORE','SUPPLIER','CUSTOMER','CARRIER')),
 contact_reference varchar(500), active boolean NOT NULL DEFAULT true
);
CREATE UNIQUE INDEX one_store_party ON party(party_kind) WHERE party_kind = 'STORE';
CREATE TABLE uom (uom_code varchar(12) PRIMARY KEY, name varchar(60) NOT NULL);
INSERT INTO uom VALUES ('PIECE','Piece'),('BOX','Box'),('M2','Square metre');
CREATE TABLE product (
 product_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 sku varchar(60) NOT NULL UNIQUE, name varchar(200) NOT NULL,
 base_uom varchar(12) NOT NULL REFERENCES uom,
 whole_base_units boolean NOT NULL DEFAULT true,
 nominal_size varchar(60), active boolean NOT NULL DEFAULT true
);
CREATE TABLE product_uom_version (
 conversion_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 product_id bigint NOT NULL REFERENCES product,
 uom_code varchar(12) NOT NULL REFERENCES uom,
 version integer NOT NULL CHECK(version > 0),
 base_per_unit numeric(24,12) NOT NULL CHECK(base_per_unit > 0),
 valid_from timestamp with time zone NOT NULL,
 UNIQUE(product_id, uom_code, version), UNIQUE(conversion_id, product_id)
);
CREATE TABLE product_warehouse_policy (
 product_id bigint REFERENCES product, warehouse_id bigint REFERENCES warehouse,
 minimum_qty numeric(20,6) NOT NULL CHECK(minimum_qty >= 0),
 PRIMARY KEY(product_id, warehouse_id)
);
CREATE TABLE lot (
 lot_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 product_id bigint NOT NULL REFERENCES product,
 manufacturer_lot varchar(100) NOT NULL,
 tone varchar(60) NOT NULL, calibre varchar(60) NOT NULL,
 identification_status varchar(12) NOT NULL CHECK(identification_status IN ('VERIFIED','UNKNOWN')),
 manufactured_on date,
 UNIQUE(product_id, manufacturer_lot, tone, calibre), UNIQUE(lot_id, product_id)
);
CREATE TABLE quality_status (quality_code varchar(16) PRIMARY KEY, name varchar(100) NOT NULL);
INSERT INTO quality_status VALUES ('PENDING','Awaiting inspection'),('GOOD','Accepted quality'),('DAMAGED','Damaged'),('BLOCKED','Blocked');

-- Relational document supertype: every business document has a real FK target.
CREATE TABLE document (
 document_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 document_no varchar(50) NOT NULL UNIQUE,
 document_kind varchar(30) NOT NULL CHECK(document_kind IN (
 'REPLENISHMENT','PO','ARRIVAL','INSPECTION','GR_PURCHASE','TO','TRANSFER_REQUEST',
 'TRANSFER_DISPATCH','MWTR','HANDOVER','ISSUE_REQUEST','OUTBOUND_DELIVERY','GI_SALE',
 'DEFECT_CASE','DISPOSITION','SCRAP','STOCKTAKE','ADJUSTMENT',
 'CUSTOMER_RETURN','GR_CUSTOMER_RETURN','SUPPLIER_RETURN','GI_SUPPLIER_RETURN',
 'SUPPLIER_ACK','DISCREPANCY','CUSTODY_RECEIPT','CUSTODY_RELEASE','REVERSAL','OPENING')),
 workflow_status varchar(30) NOT NULL DEFAULT 'DRAFT',
 version integer NOT NULL DEFAULT 1 CHECK(version > 0),
 created_by bigint NOT NULL REFERENCES app_user,
 created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
 occurred_at timestamp with time zone,
 note varchar(2000)
);
CREATE TABLE document_line (
 line_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES document,
 line_no integer NOT NULL CHECK(line_no > 0),
 product_id bigint NOT NULL REFERENCES product,
 lot_id bigint,
 conversion_id bigint NOT NULL,
 entered_qty numeric(20,6) NOT NULL CHECK(entered_qty > 0),
 conversion_snapshot numeric(24,12) NOT NULL CHECK(conversion_snapshot > 0),
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 product_name_snapshot varchar(200) NOT NULL,
 UNIQUE(document_id, line_no), UNIQUE(line_id, document_id),
 UNIQUE(line_id, product_id),
 FOREIGN KEY(lot_id, product_id) REFERENCES lot(lot_id, product_id),
 FOREIGN KEY(conversion_id, product_id) REFERENCES product_uom_version(conversion_id, product_id),
 CHECK(qty_base = round(entered_qty * conversion_snapshot, 6))
);
CREATE TABLE document_link (
 parent_document_id bigint REFERENCES document,
 child_document_id bigint REFERENCES document,
 relation_code varchar(30) NOT NULL,
 PRIMARY KEY(parent_document_id, child_document_id, relation_code),
 CHECK(parent_document_id <> child_document_id)
);
CREATE TABLE line_link (
 source_line_id bigint REFERENCES document_line,
 target_line_id bigint REFERENCES document_line,
 relation_code varchar(30) NOT NULL,
 linked_qty numeric(20,6) NOT NULL CHECK(linked_qty > 0),
 PRIMARY KEY(source_line_id, target_line_id, relation_code),
 CHECK(source_line_id <> target_line_id)
);
CREATE TABLE approval (
 approval_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES document,
 document_version integer NOT NULL CHECK(document_version > 0),
 decision_kind varchar(30) NOT NULL,
 decision varchar(12) NOT NULL CHECK(decision IN ('APPROVE','REJECT','REVISE')),
 requested_by bigint NOT NULL REFERENCES app_user,
 decided_by bigint NOT NULL REFERENCES app_user,
 decided_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
 reason varchar(2000) NOT NULL,
 UNIQUE(document_id, document_version, decision_kind),
 CHECK(requested_by <> decided_by)
);
CREATE TABLE approval_line (
 approval_id bigint REFERENCES approval, line_id bigint REFERENCES document_line,
 approved_qty numeric(20,6) NOT NULL CHECK(approved_qty >= 0),
 outcome varchar(30) NOT NULL,
 PRIMARY KEY(approval_id, line_id)
);
CREATE TABLE evidence (
 evidence_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES document,
 object_key varchar(600) NOT NULL, sha256 char(64) NOT NULL,
 media_type varchar(100) NOT NULL,
 uploaded_by bigint NOT NULL REFERENCES app_user,
 uploaded_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE external_reference (
 reference_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 source_system varchar(50) NOT NULL,
 reference_kind varchar(40) NOT NULL,
 reference_no varchar(100) NOT NULL,
 verified_by bigint REFERENCES app_user,
 verified_at timestamp with time zone,
 UNIQUE(source_system, reference_kind, reference_no)
);
CREATE TABLE document_external_reference (
 document_id bigint REFERENCES document, reference_id bigint REFERENCES external_reference,
 PRIMARY KEY(document_id, reference_id)
);
CREATE TABLE external_reference_line (
 external_line_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 reference_id bigint NOT NULL REFERENCES external_reference,
 line_key varchar(100) NOT NULL,
 product_id bigint NOT NULL REFERENCES product,
 eligible_qty numeric(20,6) NOT NULL CHECK(eligible_qty >= 0),
 UNIQUE(reference_id, line_key)
);

-- Typed headers extend document; typed lines extend document_line.
CREATE TABLE replenishment_request (
 document_id bigint PRIMARY KEY REFERENCES document,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 needed_on date NOT NULL, trigger_reason varchar(200) NOT NULL
);
CREATE TABLE purchase_order (
 document_id bigint PRIMARY KEY REFERENCES document,
 supplier_id bigint NOT NULL REFERENCES party,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 expected_on date, supplier_confirmation varchar(1000)
);
CREATE TABLE arrival (
 document_id bigint PRIMARY KEY REFERENCES document,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 supplier_id bigint REFERENCES party,
 arrived_at timestamp with time zone NOT NULL,
 delivery_reference varchar(100)
);
CREATE TABLE inspection_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 inspected_source_line_id bigint NOT NULL REFERENCES document_line,
 quality_code varchar(16) NOT NULL REFERENCES quality_status,
 ownership_decision varchar(12) NOT NULL CHECK(ownership_decision IN ('ACCEPT','CUSTODY','REJECT')),
 inspected_by bigint NOT NULL REFERENCES app_user,
 inspected_at timestamp with time zone NOT NULL
);
CREATE TABLE goods_receipt (
 document_id bigint PRIMARY KEY REFERENCES document,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 receipt_kind varchar(20) NOT NULL CHECK(receipt_kind IN ('PURCHASE','CUSTOMER_RETURN'))
);
CREATE TABLE transfer_request (
 document_id bigint PRIMARY KEY REFERENCES document,
 source_warehouse_id bigint NOT NULL REFERENCES warehouse,
 destination_warehouse_id bigint NOT NULL REFERENCES warehouse,
 needed_on date,
 CHECK(source_warehouse_id <> destination_warehouse_id)
);
CREATE TABLE transfer_dispatch (
 document_id bigint PRIMARY KEY REFERENCES document,
 request_id bigint NOT NULL REFERENCES transfer_request,
 dispatched_by bigint NOT NULL REFERENCES app_user,
 dispatched_at timestamp with time zone NOT NULL
);
CREATE TABLE transfer_receipt (
 document_id bigint PRIMARY KEY REFERENCES document,
 dispatch_id bigint NOT NULL REFERENCES transfer_dispatch,
 received_by bigint NOT NULL REFERENCES app_user,
 received_at timestamp with time zone NOT NULL
);
CREATE TABLE transfer_receipt_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 dispatch_line_id bigint NOT NULL REFERENCES document_line,
 quality_code varchar(16) NOT NULL REFERENCES quality_status
);
CREATE TABLE handover (
 document_id bigint PRIMARY KEY REFERENCES document,
 related_document_id bigint NOT NULL REFERENCES document,
 recipient_name varchar(160) NOT NULL,
 carrier_id bigint REFERENCES party,
 handed_over_at timestamp with time zone NOT NULL,
 confirmed_by bigint NOT NULL REFERENCES app_user
);
CREATE TABLE issue_request (
 document_id bigint PRIMARY KEY REFERENCES document,
 customer_id bigint NOT NULL REFERENCES party,
 requested_warehouse_id bigint NOT NULL REFERENCES warehouse,
 needed_on date NOT NULL,
 delivery_address_snapshot varchar(500) NOT NULL
);
CREATE TABLE issue_request_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 external_line_id bigint NOT NULL REFERENCES external_reference_line,
 release_key varchar(60) NOT NULL,
 required_tone varchar(60), required_calibre varchar(60),
 substitution_approval_reference varchar(300),
 UNIQUE(external_line_id, release_key)
);
CREATE TABLE outbound_delivery (
 document_id bigint PRIMARY KEY REFERENCES document,
 issue_request_id bigint NOT NULL REFERENCES issue_request,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 planned_on date NOT NULL
);
CREATE TABLE goods_issue (
 document_id bigint PRIMARY KEY REFERENCES document,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 issue_kind varchar(20) NOT NULL CHECK(issue_kind IN ('SALE','SUPPLIER_RETURN'))
);
CREATE TABLE warehouse_task (
 document_id bigint PRIMARY KEY REFERENCES document,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 task_kind varchar(20) NOT NULL CHECK(task_kind IN ('PUTAWAY','PICK','RELOCATE','QUARANTINE','UNPICK')),
 assigned_to bigint NOT NULL REFERENCES app_user
);
CREATE TABLE warehouse_task_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 from_location_id bigint NOT NULL REFERENCES location,
 to_location_id bigint NOT NULL REFERENCES location,
 quality_code varchar(16) NOT NULL REFERENCES quality_status,
 CHECK(from_location_id <> to_location_id)
);
CREATE TABLE defect_case (
 document_id bigint PRIMARY KEY REFERENCES document,
 discovered_at timestamp with time zone NOT NULL,
 reason varchar(1000) NOT NULL
);
CREATE TABLE disposition_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 defect_line_id bigint NOT NULL REFERENCES document_line,
 outcome varchar(20) NOT NULL CHECK(outcome IN ('RELEASE','REGRADE','SCRAP','RETURN_SUPPLIER')),
 approval_id bigint REFERENCES approval
);
CREATE TABLE customer_return (
 document_id bigint PRIMARY KEY REFERENCES document,
 customer_id bigint NOT NULL REFERENCES party,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 financial_followup_status varchar(20) NOT NULL DEFAULT 'NOT_RECORDED'
);
CREATE TABLE customer_return_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 original_issue_line_id bigint REFERENCES document_line,
 historical_external_line_id bigint REFERENCES external_reference_line,
 reason varchar(1000) NOT NULL,
 CHECK((original_issue_line_id IS NOT NULL AND historical_external_line_id IS NULL)
    OR (original_issue_line_id IS NULL AND historical_external_line_id IS NOT NULL))
);
CREATE TABLE supplier_return (
 document_id bigint PRIMARY KEY REFERENCES document,
 supplier_id bigint NOT NULL REFERENCES party,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 agreement_reference varchar(300), agreed_at timestamp with time zone,
 financial_followup_status varchar(20) NOT NULL DEFAULT 'NOT_RECORDED'
);
CREATE TABLE supplier_return_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 origin_line_id bigint NOT NULL REFERENCES document_line,
 owner_party_id bigint NOT NULL REFERENCES party,
 agreed_qty numeric(20,6) NOT NULL CHECK(agreed_qty >= 0),
 authorization_id bigint REFERENCES approval
);
CREATE TABLE supplier_ack_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 dispatch_line_id bigint NOT NULL REFERENCES document_line,
 outcome varchar(16) NOT NULL CHECK(outcome IN ('ACCEPTED','REJECTED','DAMAGED')),
 acknowledged_at timestamp with time zone NOT NULL
);
CREATE TABLE discrepancy_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 source_line_id bigint NOT NULL REFERENCES document_line,
 discrepancy_kind varchar(20) NOT NULL CHECK(discrepancy_kind IN ('SHORT','OVER','DAMAGED','WRONG_LOT','WRONG_PRODUCT')),
 resolution_status varchar(20) NOT NULL DEFAULT 'OPEN',
 resolution_document_id bigint REFERENCES document
);

-- A position is a physical bin OR an in-transit account dedicated to a dispatch line.
CREATE TABLE stock_account (
 account_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 location_id bigint UNIQUE REFERENCES location,
 transit_dispatch_line_id bigint UNIQUE REFERENCES document_line,
 CHECK((location_id IS NOT NULL AND transit_dispatch_line_id IS NULL)
    OR (location_id IS NULL AND transit_dispatch_line_id IS NOT NULL))
);
CREATE TABLE stock_balance (
 balance_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 account_id bigint NOT NULL REFERENCES stock_account,
 lot_id bigint NOT NULL REFERENCES lot,
 quality_code varchar(16) NOT NULL REFERENCES quality_status,
 owner_party_id bigint NOT NULL REFERENCES party,
 qty_base numeric(20,6) NOT NULL DEFAULT 0 CHECK(qty_base >= 0),
 version bigint NOT NULL DEFAULT 0,
 UNIQUE(account_id, lot_id, quality_code, owner_party_id)
);
CREATE TABLE posting_batch (
 batch_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES document,
 operation varchar(40) NOT NULL,
 operation_key varchar(100) NOT NULL,
 idempotency_key varchar(120) NOT NULL UNIQUE,
 payload_hash char(64) NOT NULL,
 posted_by bigint NOT NULL REFERENCES app_user,
 posted_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
 reversal_of bigint UNIQUE REFERENCES posting_batch,
 UNIQUE(document_id, operation, operation_key)
);
CREATE TABLE stock_movement (
 movement_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 batch_id bigint NOT NULL REFERENCES posting_batch,
 document_id bigint NOT NULL,
 line_id bigint NOT NULL,
 from_balance_id bigint REFERENCES stock_balance,
 to_balance_id bigint REFERENCES stock_balance,
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 from_before numeric(20,6), from_after numeric(20,6),
 to_before numeric(20,6), to_after numeric(20,6),
 FOREIGN KEY(line_id, document_id) REFERENCES document_line(line_id, document_id),
 CHECK(from_balance_id IS NOT NULL OR to_balance_id IS NOT NULL),
 CHECK(from_balance_id IS NULL OR to_balance_id IS NULL OR from_balance_id <> to_balance_id),
 CHECK((from_balance_id IS NULL AND from_before IS NULL AND from_after IS NULL)
   OR (from_balance_id IS NOT NULL AND from_before IS NOT NULL AND from_after IS NOT NULL
       AND from_after = from_before - qty_base AND from_after >= 0)),
 CHECK((to_balance_id IS NULL AND to_before IS NULL AND to_after IS NULL)
   OR (to_balance_id IS NOT NULL AND to_before IS NOT NULL AND to_after IS NOT NULL
       AND to_after = to_before + qty_base AND to_before >= 0))
);
CREATE TABLE reservation (
 reservation_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 demand_line_id bigint NOT NULL REFERENCES document_line,
 execution_line_id bigint NOT NULL REFERENCES document_line,
 balance_id bigint NOT NULL REFERENCES stock_balance,
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 status varchar(12) NOT NULL CHECK(status IN ('ACTIVE','CONSUMED','RELEASED')),
 created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE demand_supply_allocation (
 demand_line_id bigint REFERENCES document_line,
 supply_line_id bigint REFERENCES document_line,
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 status varchar(12) NOT NULL CHECK(status IN ('PLANNED','FULFILLED','CANCELLED')),
 PRIMARY KEY(demand_line_id, supply_line_id)
);
CREATE TABLE stocktake (
 document_id bigint PRIMARY KEY REFERENCES document,
 warehouse_id bigint NOT NULL REFERENCES warehouse,
 cutoff_at timestamp with time zone,
 completed_at timestamp with time zone,
 mode varchar(12) NOT NULL DEFAULT 'FROZEN' CHECK(mode = 'FROZEN')
);
CREATE TABLE stocktake_scope (
 stocktake_id bigint REFERENCES stocktake(document_id),
 location_id bigint REFERENCES location,
 PRIMARY KEY(stocktake_id, location_id)
);
CREATE TABLE location_lock (
 location_id bigint PRIMARY KEY REFERENCES location,
 stocktake_id bigint NOT NULL REFERENCES stocktake(document_id),
 locked_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(stocktake_id, location_id) REFERENCES stocktake_scope(stocktake_id, location_id)
);
CREATE TABLE stocktake_snapshot (
 snapshot_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 stocktake_id bigint NOT NULL REFERENCES stocktake(document_id),
 balance_id bigint NOT NULL REFERENCES stock_balance,
 book_qty numeric(20,6) NOT NULL CHECK(book_qty >= 0),
 found_after_cutoff boolean NOT NULL DEFAULT false,
 UNIQUE(stocktake_id, balance_id)
);
CREATE TABLE count_attempt (
 count_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 snapshot_id bigint NOT NULL REFERENCES stocktake_snapshot,
 attempt_no integer NOT NULL CHECK(attempt_no > 0),
 counted_qty numeric(20,6) NOT NULL CHECK(counted_qty >= 0),
 counted_by bigint NOT NULL REFERENCES app_user,
 counted_at timestamp with time zone NOT NULL,
 UNIQUE(snapshot_id, attempt_no)
);
CREATE TABLE adjustment_line (
 line_id bigint PRIMARY KEY REFERENCES document_line,
 count_id bigint NOT NULL REFERENCES count_attempt,
 approval_id bigint REFERENCES approval,
 delta_qty numeric(20,6) NOT NULL CHECK(delta_qty <> 0)
);
CREATE TABLE audit_event (
 event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 document_id bigint REFERENCES document,
 actor_id bigint NOT NULL REFERENCES app_user,
 action varchar(80) NOT NULL,
 event_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
 details varchar(4000) NOT NULL
);
CREATE TABLE outbox_event (
 event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES document,
 event_type varchar(60) NOT NULL,
 event_key varchar(120) NOT NULL UNIQUE,
 created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
 delivered_at timestamp with time zone,
 attempts integer NOT NULL DEFAULT 0 CHECK(attempts >= 0)
);

CREATE INDEX ix_document_kind_status ON document(document_kind, workflow_status, created_at);
CREATE INDEX ix_line_lot ON document_line(lot_id);
CREATE INDEX ix_line_link_target ON line_link(target_line_id);
CREATE INDEX ix_receipt_dispatch ON transfer_receipt(dispatch_id);
CREATE INDEX ix_receipt_line_dispatch ON transfer_receipt_line(dispatch_line_id);
CREATE INDEX ix_movement_from ON stock_movement(from_balance_id, batch_id);
CREATE INDEX ix_movement_to ON stock_movement(to_balance_id, batch_id);
CREATE INDEX ix_batch_posted ON posting_batch(posted_at);
CREATE INDEX ix_reservation_active ON reservation(balance_id) WHERE status = 'ACTIVE';
CREATE INDEX ix_reservation_demand ON reservation(demand_line_id, status);
CREATE INDEX ix_balance_lot ON stock_balance(lot_id, quality_code);
CREATE INDEX ix_pending_outbox ON outbox_event(event_id) WHERE delivered_at IS NULL;

CREATE VIEW inventory_ledger AS
 SELECT movement_id, batch_id, from_balance_id AS balance_id, -qty_base AS delta_qty
 FROM stock_movement WHERE from_balance_id IS NOT NULL
 UNION ALL
 SELECT movement_id, batch_id, to_balance_id AS balance_id, qty_base AS delta_qty
 FROM stock_movement WHERE to_balance_id IS NOT NULL;

-- Free stock for NEW demand. Reserved staged/transit stock stays assigned to its demand.
CREATE VIEW available_stock AS
 SELECT b.balance_id, l.warehouse_id, l.location_id, b.lot_id,
        b.qty_base - COALESCE(r.reserved_qty,0) AS available_qty
 FROM stock_balance b
 JOIN stock_account a ON a.account_id=b.account_id
 JOIN location l ON l.location_id=a.location_id
 JOIN warehouse w ON w.warehouse_id=l.warehouse_id
 JOIN party p ON p.party_id=b.owner_party_id
 JOIN lot lot_ref ON lot_ref.lot_id=b.lot_id
 JOIN product pr ON pr.product_id=lot_ref.product_id
 LEFT JOIN (SELECT balance_id, SUM(qty_base) AS reserved_qty FROM reservation
            WHERE status='ACTIVE' GROUP BY balance_id) r ON r.balance_id=b.balance_id
 WHERE p.party_kind='STORE' AND b.quality_code='GOOD'
   AND lot_ref.identification_status='VERIFIED' AND pr.active
   AND l.active AND w.active AND l.allocatable
   AND NOT EXISTS (SELECT 1 FROM location_lock k WHERE k.location_id=l.location_id);

COMMIT;
-- REQUIRED APPLICATION/STORED-PROCEDURE CONTROLS (not supplied by DDL):
-- 1. Typed-header/line kind consistency, source/product/lot/warehouse matching.
-- 2. Append-only posted records; disallow arbitrary DML by application identities.
-- 3. Lock affected stock_balance rows in ascending ID; verify cumulative source limits.
-- 4. Atomically write movement, balances, reservations, status, audit and outbox.
-- 5. Recheck active location_lock under a shared location-row locking protocol.
-- 6. Approved document version, actual requester identity and per-line approval ceiling.
-- 7. Independent transfer receiver, role + warehouse + operation authorization.
-- 8. Sum ACTIVE reservations <= balance; do not reserve inbound plans as on-hand stock.
-- 9. Whole-unit quantities, immutable conversions, verified-lot requirements.
-- 10. Batch.document_id = movement.document_id; cumulative posting <= source allowance.
