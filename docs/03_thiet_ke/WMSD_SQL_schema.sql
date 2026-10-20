-- WMSD relational analysis/reference DDL, 2026-10-18. NOT a production schema.
-- Runtime persistence remains MongoDB (NoSQL), per Report 3 and the system design.
-- SQL Server (T-SQL) syntax is used only to make the proposed relational model executable for review.
-- Schema only: posting/approval services and authorization are NOT implemented here.
-- Read the VI/EN proposal for cross-row rules and transaction boundaries.
-- Self-contained SQL Server reference DDL for design review only; never run as the MongoDB runtime schema.
-- Survey alignment 2026-10-20: D1-D5 retain PGI, departmental entry, five roles,
-- independent transfers and FROZEN stocktake. D6 adds versioned return assessment.
-- D7 does not seed invented warehouse names, conversion factors or return periods.
BEGIN TRANSACTION;
GO
CREATE SCHEMA wmsd;
GO

CREATE TABLE wmsd.app_user (
 user_id bigint IDENTITY(1,1) PRIMARY KEY,
 username varchar(100) NOT NULL UNIQUE,
 display_name varchar(160) NOT NULL,
 credential_hash varchar(255) NOT NULL,
 active bit NOT NULL DEFAULT 1
);
CREATE TABLE wmsd.app_role (role_code varchar(30) PRIMARY KEY);
INSERT INTO wmsd.app_role VALUES ('OWNER'),('SALES'),('WAREHOUSE'),('ACCOUNTANT'),('ADMIN');
CREATE TABLE wmsd.user_role (
 user_id bigint NOT NULL REFERENCES wmsd.app_user, role_code varchar(30) NOT NULL REFERENCES wmsd.app_role,
 PRIMARY KEY(user_id, role_code)
);
CREATE TABLE wmsd.permission (permission_code varchar(80) PRIMARY KEY);
CREATE TABLE wmsd.role_permission (
 role_code varchar(30) NOT NULL REFERENCES wmsd.app_role, permission_code varchar(80) NOT NULL REFERENCES wmsd.permission,
 PRIMARY KEY(role_code, permission_code)
);
CREATE TABLE wmsd.warehouse (
 warehouse_id bigint IDENTITY(1,1) PRIMARY KEY,
 code varchar(30) NOT NULL UNIQUE, name varchar(160) NOT NULL,
 address varchar(500), active bit NOT NULL DEFAULT 1
);
CREATE TABLE wmsd.user_warehouse (
 user_id bigint NOT NULL REFERENCES wmsd.app_user, warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 PRIMARY KEY(user_id, warehouse_id)
);
CREATE TABLE wmsd.location (
 location_id bigint IDENTITY(1,1) PRIMARY KEY,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 code varchar(50) NOT NULL,
 location_kind varchar(20) NOT NULL CHECK(location_kind IN ('RECEIVING','STORAGE','STAGING','QUARANTINE','CUSTODY')),
 allocatable bit NOT NULL DEFAULT 0,
 active bit NOT NULL DEFAULT 1,
 UNIQUE(warehouse_id, code), UNIQUE(location_id, warehouse_id),
 CHECK(allocatable = 0 OR location_kind = 'STORAGE')
);
CREATE TABLE wmsd.party (
 party_id bigint IDENTITY(1,1) PRIMARY KEY,
 code varchar(40) NOT NULL UNIQUE, name varchar(200) NOT NULL,
 party_kind varchar(12) NOT NULL CHECK(party_kind IN ('STORE','SUPPLIER','CUSTOMER','CARRIER')),
 contact_reference varchar(500), active bit NOT NULL DEFAULT 1
);
CREATE UNIQUE INDEX one_store_party ON wmsd.party(party_kind) WHERE party_kind = 'STORE';
CREATE TABLE wmsd.uom (uom_code varchar(12) PRIMARY KEY, name varchar(60) NOT NULL);
INSERT INTO wmsd.uom VALUES ('PIECE','Piece'),('BOX','Box'),('M2','Square metre');
CREATE TABLE wmsd.product (
 product_id bigint IDENTITY(1,1) PRIMARY KEY,
 sku varchar(60) NOT NULL UNIQUE, name varchar(200) NOT NULL,
 base_uom varchar(12) NOT NULL REFERENCES wmsd.uom,
 whole_base_units bit NOT NULL DEFAULT 1,
 nominal_size varchar(60), active bit NOT NULL DEFAULT 1
);
CREATE TABLE wmsd.product_uom_version (
 conversion_id bigint IDENTITY(1,1) PRIMARY KEY,
 product_id bigint NOT NULL REFERENCES wmsd.product,
 uom_code varchar(12) NOT NULL REFERENCES wmsd.uom,
 version integer NOT NULL CHECK(version > 0),
 base_per_unit numeric(24,12) NOT NULL CHECK(base_per_unit > 0),
 valid_from datetimeoffset NOT NULL,
 UNIQUE(product_id, uom_code, version), UNIQUE(conversion_id, product_id)
);
CREATE TABLE wmsd.product_warehouse_policy (
 product_id bigint NOT NULL REFERENCES wmsd.product, warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 minimum_qty numeric(20,6) NOT NULL CHECK(minimum_qty >= 0),
 PRIMARY KEY(product_id, warehouse_id)
);
CREATE TABLE wmsd.lot (
 lot_id bigint IDENTITY(1,1) PRIMARY KEY,
 product_id bigint NOT NULL REFERENCES wmsd.product,
 manufacturer_lot varchar(100) NOT NULL,
 tone varchar(60) NOT NULL, calibre varchar(60) NOT NULL,
 identification_status varchar(12) NOT NULL CHECK(identification_status IN ('VERIFIED','UNKNOWN')),
 manufactured_on date,
 UNIQUE(product_id, manufacturer_lot, tone, calibre), UNIQUE(lot_id, product_id)
);
CREATE TABLE wmsd.quality_status (quality_code varchar(16) PRIMARY KEY, name varchar(100) NOT NULL);
INSERT INTO wmsd.quality_status VALUES ('PENDING','Awaiting inspection'),('GOOD','Accepted quality'),('DAMAGED','Damaged'),('BLOCKED','Blocked');

-- Relational document supertype: every business document has a real FK target.
CREATE TABLE wmsd.document (
 document_id bigint IDENTITY(1,1) PRIMARY KEY,
 document_no varchar(50) NOT NULL UNIQUE,
 document_kind varchar(30) NOT NULL CHECK(document_kind IN (
 'REPLENISHMENT','PO','ARRIVAL','INSPECTION','GR_PURCHASE','TO','TRANSFER_REQUEST',
 'TRANSFER_DISPATCH','MWTR','HANDOVER','ISSUE_REQUEST','OUTBOUND_DELIVERY','GI_SALE',
 'DEFECT_CASE','DISPOSITION','SCRAP','STOCKTAKE','ADJUSTMENT',
 'CUSTOMER_RETURN','GR_CUSTOMER_RETURN','SUPPLIER_RETURN','GI_SUPPLIER_RETURN',
 'SUPPLIER_ACK','DISCREPANCY','CUSTODY_RECEIPT','CUSTODY_RELEASE','REVERSAL','OPENING')),
 workflow_status varchar(30) NOT NULL DEFAULT 'DRAFT',
 version integer NOT NULL DEFAULT 1 CHECK(version > 0),
 created_by bigint NOT NULL REFERENCES wmsd.app_user,
 created_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET(),
 occurred_at datetimeoffset,
 note varchar(2000)
);
CREATE TABLE wmsd.document_line (
 line_id bigint IDENTITY(1,1) PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES wmsd.document,
 line_no integer NOT NULL CHECK(line_no > 0),
 product_id bigint NOT NULL REFERENCES wmsd.product,
 lot_id bigint,
 conversion_id bigint NOT NULL,
 entered_qty numeric(20,6) NOT NULL CHECK(entered_qty > 0),
 conversion_snapshot numeric(24,12) NOT NULL CHECK(conversion_snapshot > 0),
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 product_name_snapshot varchar(200) NOT NULL,
 UNIQUE(document_id, line_no), UNIQUE(line_id, document_id),
 UNIQUE(line_id, product_id),
 FOREIGN KEY(lot_id, product_id) REFERENCES wmsd.lot(lot_id, product_id),
 FOREIGN KEY(conversion_id, product_id) REFERENCES wmsd.product_uom_version(conversion_id, product_id),
 CHECK(qty_base = round(entered_qty * conversion_snapshot, 6))
);
CREATE TABLE wmsd.document_link (
 parent_document_id bigint NOT NULL REFERENCES wmsd.document,
 child_document_id bigint NOT NULL REFERENCES wmsd.document,
 relation_code varchar(30) NOT NULL,
 PRIMARY KEY(parent_document_id, child_document_id, relation_code),
 CHECK(parent_document_id <> child_document_id)
);
CREATE TABLE wmsd.line_link (
 source_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 target_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 relation_code varchar(30) NOT NULL,
 linked_qty numeric(20,6) NOT NULL CHECK(linked_qty > 0),
 PRIMARY KEY(source_line_id, target_line_id, relation_code),
 CHECK(source_line_id <> target_line_id)
);
CREATE TABLE wmsd.approval (
 approval_id bigint IDENTITY(1,1) PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES wmsd.document,
 document_version integer NOT NULL CHECK(document_version > 0),
 decision_kind varchar(30) NOT NULL,
 decision varchar(12) NOT NULL CHECK(decision IN ('APPROVE','REJECT','REVISE')),
 requested_by bigint NOT NULL REFERENCES wmsd.app_user,
 decided_by bigint NOT NULL REFERENCES wmsd.app_user,
 decided_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET(),
 reason varchar(2000) NOT NULL,
 UNIQUE(document_id, document_version, decision_kind),
 CHECK(requested_by <> decided_by)
);
CREATE TABLE wmsd.approval_line (
 approval_id bigint NOT NULL REFERENCES wmsd.approval, line_id bigint NOT NULL REFERENCES wmsd.document_line,
 approved_qty numeric(20,6) NOT NULL CHECK(approved_qty >= 0),
 outcome varchar(30) NOT NULL,
 PRIMARY KEY(approval_id, line_id)
);
CREATE TABLE wmsd.evidence (
 evidence_id bigint IDENTITY(1,1) PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES wmsd.document,
 object_key varchar(600) NOT NULL, sha256 char(64) NOT NULL,
 media_type varchar(100) NOT NULL,
 uploaded_by bigint NOT NULL REFERENCES wmsd.app_user,
 uploaded_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
CREATE TABLE wmsd.external_reference (
 reference_id bigint IDENTITY(1,1) PRIMARY KEY,
 source_system varchar(50) NOT NULL,
 reference_kind varchar(40) NOT NULL,
 reference_no varchar(100) NOT NULL,
 verified_by bigint REFERENCES wmsd.app_user,
 verified_at datetimeoffset,
 UNIQUE(source_system, reference_kind, reference_no)
);
CREATE TABLE wmsd.document_external_reference (
 document_id bigint NOT NULL REFERENCES wmsd.document, reference_id bigint NOT NULL REFERENCES wmsd.external_reference,
 PRIMARY KEY(document_id, reference_id)
);
CREATE TABLE wmsd.external_reference_line (
 external_line_id bigint IDENTITY(1,1) PRIMARY KEY,
 reference_id bigint NOT NULL REFERENCES wmsd.external_reference,
 line_key varchar(100) NOT NULL,
 product_id bigint NOT NULL REFERENCES wmsd.product,
 eligible_qty numeric(20,6) NOT NULL CHECK(eligible_qty >= 0),
 UNIQUE(reference_id, line_key)
);

-- Typed headers extend document; typed lines extend document_line.
CREATE TABLE wmsd.replenishment_request (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 needed_on date NOT NULL, trigger_reason varchar(200) NOT NULL
);
CREATE TABLE wmsd.purchase_order (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 supplier_id bigint NOT NULL REFERENCES wmsd.party,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 expected_on date, supplier_confirmation varchar(1000)
);
CREATE TABLE wmsd.arrival (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 supplier_id bigint REFERENCES wmsd.party,
 arrived_at datetimeoffset NOT NULL,
 delivery_reference varchar(100)
);
CREATE TABLE wmsd.inspection_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 inspected_source_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 quality_code varchar(16) NOT NULL REFERENCES wmsd.quality_status,
 ownership_decision varchar(12) NOT NULL CHECK(ownership_decision IN ('ACCEPT','CUSTODY','REJECT')),
 inspected_by bigint NOT NULL REFERENCES wmsd.app_user,
 inspected_at datetimeoffset NOT NULL
);
CREATE TABLE wmsd.goods_receipt (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 receipt_kind varchar(20) NOT NULL CHECK(receipt_kind IN ('PURCHASE','CUSTOMER_RETURN'))
);
CREATE TABLE wmsd.transfer_request (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 source_warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 destination_warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 needed_on date,
 CHECK(source_warehouse_id <> destination_warehouse_id)
);
CREATE TABLE wmsd.transfer_dispatch (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 request_id bigint NOT NULL REFERENCES wmsd.transfer_request,
 dispatched_by bigint NOT NULL REFERENCES wmsd.app_user,
 dispatched_at datetimeoffset NOT NULL
);
CREATE TABLE wmsd.transfer_receipt (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 dispatch_id bigint NOT NULL REFERENCES wmsd.transfer_dispatch,
 received_by bigint NOT NULL REFERENCES wmsd.app_user,
 received_at datetimeoffset NOT NULL
);
CREATE TABLE wmsd.transfer_receipt_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 dispatch_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 quality_code varchar(16) NOT NULL REFERENCES wmsd.quality_status
);
CREATE TABLE wmsd.handover (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 related_document_id bigint NOT NULL REFERENCES wmsd.document,
 recipient_name varchar(160) NOT NULL,
 carrier_id bigint REFERENCES wmsd.party,
 handed_over_at datetimeoffset NOT NULL,
 confirmed_by bigint NOT NULL REFERENCES wmsd.app_user
);
CREATE TABLE wmsd.issue_request (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 customer_id bigint NOT NULL REFERENCES wmsd.party,
 requested_warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 needed_on date NOT NULL,
 delivery_address_snapshot varchar(500) NOT NULL
);
CREATE TABLE wmsd.issue_request_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 external_line_id bigint NOT NULL REFERENCES wmsd.external_reference_line,
 release_key varchar(60) NOT NULL,
 required_tone varchar(60), required_calibre varchar(60),
 substitution_approval_reference varchar(300),
 UNIQUE(external_line_id, release_key)
);
CREATE TABLE wmsd.outbound_delivery (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 issue_request_id bigint NOT NULL REFERENCES wmsd.issue_request,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 planned_on date NOT NULL
);
CREATE TABLE wmsd.goods_issue (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 issue_kind varchar(20) NOT NULL CHECK(issue_kind IN ('SALE','SUPPLIER_RETURN'))
);
CREATE TABLE wmsd.warehouse_task (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 task_kind varchar(20) NOT NULL CHECK(task_kind IN ('PUTAWAY','PICK','RELOCATE','QUARANTINE','UNPICK')),
 assigned_to bigint NOT NULL REFERENCES wmsd.app_user
);
CREATE TABLE wmsd.warehouse_task_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 from_location_id bigint NOT NULL REFERENCES wmsd.location,
 to_location_id bigint NOT NULL REFERENCES wmsd.location,
 quality_code varchar(16) NOT NULL REFERENCES wmsd.quality_status,
 CHECK(from_location_id <> to_location_id)
);
CREATE TABLE wmsd.defect_case (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 discovered_at datetimeoffset NOT NULL,
 reason varchar(1000) NOT NULL
);
CREATE TABLE wmsd.disposition_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 defect_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 outcome varchar(20) NOT NULL CHECK(outcome IN ('RELEASE','REGRADE','SCRAP','RETURN_SUPPLIER')),
 approval_id bigint REFERENCES wmsd.approval
);
CREATE TABLE wmsd.customer_return (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 customer_id bigint NOT NULL REFERENCES wmsd.party,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 financial_followup_status varchar(20) NOT NULL DEFAULT 'NOT_RECORDED'
);
CREATE TABLE wmsd.customer_return_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 original_issue_line_id bigint REFERENCES wmsd.document_line,
 historical_external_line_id bigint REFERENCES wmsd.external_reference_line,
 reason varchar(1000) NOT NULL,
 CHECK((original_issue_line_id IS NOT NULL AND historical_external_line_id IS NULL)
    OR (original_issue_line_id IS NULL AND historical_external_line_id IS NOT NULL))
);
-- D6: one return line represents a quantity with homogeneous eligibility conditions.
-- Split mixed quantities into separate lines. Assessment is evidence, NOT acceptance
-- or a stock posting. Owner approval still follows Warehouse inspection (UC-71/72).
-- Unknown is explicit; no default number of return days is introduced.
CREATE TABLE wmsd.customer_return_assessment (
 assessment_id bigint IDENTITY(1,1) PRIMARY KEY,
 return_line_id bigint NOT NULL REFERENCES wmsd.customer_return_line(line_id),
 assessment_no integer NOT NULL CHECK(assessment_no > 0),
 document_version integer NOT NULL CHECK(document_version > 0),
 packaging_condition varchar(12) NOT NULL
   CHECK(packaging_condition IN ('SEALED','OPENED','TORN','UNKNOWN')),
 installation_status varchar(12) NOT NULL
   CHECK(installation_status IN ('UNUSED','INSTALLED','UNKNOWN')),
 damage_cause varchar(12) NOT NULL
   CHECK(damage_cause IN ('NONE','CUSTOMER','SUPPLIER','OTHER','UNKNOWN')),
 deadline_status varchar(16) NOT NULL
   CHECK(deadline_status IN ('WITHIN','EXCEEDED','NOT_APPLICABLE','UNKNOWN')),
 deadline_reference nvarchar(1000),
 eligibility_status varchar(16) NOT NULL
   CHECK(eligibility_status IN ('PENDING','CASE_REVIEW','INELIGIBLE')),
 assessment_reason nvarchar(2000) NOT NULL,
 assessed_by bigint NOT NULL REFERENCES wmsd.app_user,
 assessed_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET(),
 approval_id bigint REFERENCES wmsd.approval,
 UNIQUE(return_line_id, assessment_no),
 CONSTRAINT ck_return_deadline_evidence CHECK(
   deadline_status = 'UNKNOWN'
   OR (deadline_reference IS NOT NULL AND LEN(LTRIM(RTRIM(deadline_reference))) > 0)),
 CONSTRAINT ck_return_eligibility CHECK(
   (eligibility_status = 'INELIGIBLE'
     AND (installation_status = 'INSTALLED' OR damage_cause = 'CUSTOMER'
          OR deadline_status = 'EXCEEDED'))
   OR (eligibility_status = 'CASE_REVIEW'
     AND packaging_condition <> 'UNKNOWN' AND installation_status = 'UNUSED'
     AND damage_cause IN ('NONE','SUPPLIER','OTHER')
     AND deadline_status IN ('WITHIN','NOT_APPLICABLE'))
   OR (eligibility_status = 'PENDING'
     AND installation_status <> 'INSTALLED' AND damage_cause <> 'CUSTOMER'
     AND deadline_status <> 'EXCEEDED'
     AND (packaging_condition = 'UNKNOWN' OR installation_status = 'UNKNOWN'
          OR damage_cause = 'UNKNOWN' OR deadline_status = 'UNKNOWN')))
);
-- SEALED/OPENED/TORN are packaging observations, not quality grades or automatic
-- acceptance. Supplier-defective goods may be accepted into quarantine after review.
CREATE TABLE wmsd.supplier_return (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 supplier_id bigint NOT NULL REFERENCES wmsd.party,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 agreement_reference varchar(300), agreed_at datetimeoffset,
 financial_followup_status varchar(20) NOT NULL DEFAULT 'NOT_RECORDED'
);
CREATE TABLE wmsd.supplier_return_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 origin_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 owner_party_id bigint NOT NULL REFERENCES wmsd.party,
 agreed_qty numeric(20,6) NOT NULL CHECK(agreed_qty >= 0),
 authorization_id bigint REFERENCES wmsd.approval
);
CREATE TABLE wmsd.supplier_ack_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 dispatch_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 outcome varchar(16) NOT NULL CHECK(outcome IN ('ACCEPTED','REJECTED','DAMAGED')),
 acknowledged_at datetimeoffset NOT NULL
);
CREATE TABLE wmsd.discrepancy_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 source_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 discrepancy_kind varchar(20) NOT NULL CHECK(discrepancy_kind IN ('SHORT','OVER','DAMAGED','WRONG_LOT','WRONG_PRODUCT')),
 resolution_status varchar(20) NOT NULL DEFAULT 'OPEN',
 resolution_document_id bigint REFERENCES wmsd.document
);

-- A position is a physical bin OR an in-transit account dedicated to a dispatch line.
CREATE TABLE wmsd.stock_account (
 account_id bigint IDENTITY(1,1) PRIMARY KEY,
 location_id bigint REFERENCES wmsd.location,
 transit_dispatch_line_id bigint REFERENCES wmsd.document_line,
 CHECK((location_id IS NOT NULL AND transit_dispatch_line_id IS NULL)
    OR (location_id IS NULL AND transit_dispatch_line_id IS NOT NULL))
);
CREATE UNIQUE INDEX ux_stock_account_location ON wmsd.stock_account(location_id) WHERE location_id IS NOT NULL;
CREATE UNIQUE INDEX ux_stock_account_transit_dispatch_line ON wmsd.stock_account(transit_dispatch_line_id) WHERE transit_dispatch_line_id IS NOT NULL;
CREATE TABLE wmsd.stock_balance (
 balance_id bigint IDENTITY(1,1) PRIMARY KEY,
 account_id bigint NOT NULL REFERENCES wmsd.stock_account,
 lot_id bigint NOT NULL REFERENCES wmsd.lot,
 quality_code varchar(16) NOT NULL REFERENCES wmsd.quality_status,
 owner_party_id bigint NOT NULL REFERENCES wmsd.party,
 qty_base numeric(20,6) NOT NULL DEFAULT 0 CHECK(qty_base >= 0),
 version bigint NOT NULL DEFAULT 0,
 UNIQUE(account_id, lot_id, quality_code, owner_party_id)
);
CREATE TABLE wmsd.posting_batch (
 batch_id bigint IDENTITY(1,1) PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES wmsd.document,
 operation varchar(40) NOT NULL,
 operation_key varchar(100) NOT NULL,
 idempotency_key varchar(120) NOT NULL UNIQUE,
 payload_hash char(64) NOT NULL,
 posted_by bigint NOT NULL REFERENCES wmsd.app_user,
 posted_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET(),
 reversal_of bigint REFERENCES wmsd.posting_batch,
 UNIQUE(document_id, operation, operation_key)
);
CREATE UNIQUE INDEX ux_posting_batch_reversal_of ON wmsd.posting_batch(reversal_of) WHERE reversal_of IS NOT NULL;
CREATE TABLE wmsd.stock_movement (
 movement_id bigint IDENTITY(1,1) PRIMARY KEY,
 batch_id bigint NOT NULL REFERENCES wmsd.posting_batch,
 document_id bigint NOT NULL,
 line_id bigint NOT NULL,
 from_balance_id bigint REFERENCES wmsd.stock_balance,
 to_balance_id bigint REFERENCES wmsd.stock_balance,
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 from_before numeric(20,6), from_after numeric(20,6),
 to_before numeric(20,6), to_after numeric(20,6),
 FOREIGN KEY(line_id, document_id) REFERENCES wmsd.document_line(line_id, document_id),
 CHECK(from_balance_id IS NOT NULL OR to_balance_id IS NOT NULL),
 CHECK(from_balance_id IS NULL OR to_balance_id IS NULL OR from_balance_id <> to_balance_id),
 CHECK((from_balance_id IS NULL AND from_before IS NULL AND from_after IS NULL)
   OR (from_balance_id IS NOT NULL AND from_before IS NOT NULL AND from_after IS NOT NULL
       AND from_after = from_before - qty_base AND from_after >= 0)),
 CHECK((to_balance_id IS NULL AND to_before IS NULL AND to_after IS NULL)
   OR (to_balance_id IS NOT NULL AND to_before IS NOT NULL AND to_after IS NOT NULL
       AND to_after = to_before + qty_base AND to_before >= 0))
);
CREATE TABLE wmsd.reservation (
 reservation_id bigint IDENTITY(1,1) PRIMARY KEY,
 demand_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 execution_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 balance_id bigint NOT NULL REFERENCES wmsd.stock_balance,
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 status varchar(12) NOT NULL CHECK(status IN ('ACTIVE','CONSUMED','RELEASED')),
 created_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET()
);
CREATE TABLE wmsd.demand_supply_allocation (
 demand_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 supply_line_id bigint NOT NULL REFERENCES wmsd.document_line,
 qty_base numeric(20,6) NOT NULL CHECK(qty_base > 0),
 status varchar(12) NOT NULL CHECK(status IN ('PLANNED','FULFILLED','CANCELLED')),
 PRIMARY KEY(demand_line_id, supply_line_id)
);
CREATE TABLE wmsd.stocktake (
 document_id bigint PRIMARY KEY REFERENCES wmsd.document,
 warehouse_id bigint NOT NULL REFERENCES wmsd.warehouse,
 cutoff_at datetimeoffset,
 completed_at datetimeoffset,
 mode varchar(12) NOT NULL DEFAULT 'FROZEN' CHECK(mode = 'FROZEN')
);
CREATE TABLE wmsd.stocktake_scope (
 stocktake_id bigint NOT NULL REFERENCES wmsd.stocktake(document_id),
 location_id bigint NOT NULL REFERENCES wmsd.location,
 PRIMARY KEY(stocktake_id, location_id)
);
CREATE TABLE wmsd.location_lock (
 location_id bigint PRIMARY KEY REFERENCES wmsd.location,
 stocktake_id bigint NOT NULL REFERENCES wmsd.stocktake(document_id),
 locked_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET(),
 FOREIGN KEY(stocktake_id, location_id) REFERENCES wmsd.stocktake_scope(stocktake_id, location_id)
);
CREATE TABLE wmsd.stocktake_snapshot (
 snapshot_id bigint IDENTITY(1,1) PRIMARY KEY,
 stocktake_id bigint NOT NULL REFERENCES wmsd.stocktake(document_id),
 balance_id bigint NOT NULL REFERENCES wmsd.stock_balance,
 book_qty numeric(20,6) NOT NULL CHECK(book_qty >= 0),
 found_after_cutoff bit NOT NULL DEFAULT 0,
 UNIQUE(stocktake_id, balance_id)
);
CREATE TABLE wmsd.count_attempt (
 count_id bigint IDENTITY(1,1) PRIMARY KEY,
 snapshot_id bigint NOT NULL REFERENCES wmsd.stocktake_snapshot,
 attempt_no integer NOT NULL CHECK(attempt_no > 0),
 counted_qty numeric(20,6) NOT NULL CHECK(counted_qty >= 0),
 counted_by bigint NOT NULL REFERENCES wmsd.app_user,
 counted_at datetimeoffset NOT NULL,
 UNIQUE(snapshot_id, attempt_no)
);
CREATE TABLE wmsd.adjustment_line (
 line_id bigint PRIMARY KEY REFERENCES wmsd.document_line,
 count_id bigint NOT NULL REFERENCES wmsd.count_attempt,
 approval_id bigint REFERENCES wmsd.approval,
 delta_qty numeric(20,6) NOT NULL CHECK(delta_qty <> 0)
);
CREATE TABLE wmsd.audit_event (
 event_id bigint IDENTITY(1,1) PRIMARY KEY,
 document_id bigint REFERENCES wmsd.document,
 actor_id bigint NOT NULL REFERENCES wmsd.app_user,
 action varchar(80) NOT NULL,
 event_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET(),
 details varchar(4000) NOT NULL
);
CREATE TABLE wmsd.outbox_event (
 event_id bigint IDENTITY(1,1) PRIMARY KEY,
 document_id bigint NOT NULL REFERENCES wmsd.document,
 event_type varchar(60) NOT NULL,
 event_key varchar(120) NOT NULL UNIQUE,
 created_at datetimeoffset NOT NULL DEFAULT SYSDATETIMEOFFSET(),
 delivered_at datetimeoffset,
 attempts integer NOT NULL DEFAULT 0 CHECK(attempts >= 0)
);

CREATE INDEX ix_document_kind_status ON wmsd.document(document_kind, workflow_status, created_at);
CREATE INDEX ix_line_lot ON wmsd.document_line(lot_id);
CREATE INDEX ix_line_link_target ON wmsd.line_link(target_line_id);
CREATE INDEX ix_receipt_dispatch ON wmsd.transfer_receipt(dispatch_id);
CREATE INDEX ix_receipt_line_dispatch ON wmsd.transfer_receipt_line(dispatch_line_id);
CREATE INDEX ix_movement_from ON wmsd.stock_movement(from_balance_id, batch_id);
CREATE INDEX ix_movement_to ON wmsd.stock_movement(to_balance_id, batch_id);
CREATE INDEX ix_batch_posted ON wmsd.posting_batch(posted_at);
CREATE INDEX ix_reservation_active ON wmsd.reservation(balance_id) WHERE status = 'ACTIVE';
CREATE INDEX ix_reservation_demand ON wmsd.reservation(demand_line_id, status);
CREATE INDEX ix_balance_lot ON wmsd.stock_balance(lot_id, quality_code);
CREATE INDEX ix_pending_outbox ON wmsd.outbox_event(event_id) WHERE delivered_at IS NULL;
CREATE INDEX ix_return_assessment_status ON wmsd.customer_return_assessment(eligibility_status, return_line_id);
GO

CREATE VIEW wmsd.inventory_ledger AS
 SELECT movement_id, batch_id, from_balance_id AS balance_id, -qty_base AS delta_qty
 FROM wmsd.stock_movement WHERE from_balance_id IS NOT NULL
 UNION ALL
 SELECT movement_id, batch_id, to_balance_id AS balance_id, qty_base AS delta_qty
 FROM wmsd.stock_movement WHERE to_balance_id IS NOT NULL;
GO

-- Free stock for NEW demand. Reserved staged/transit stock stays assigned to its demand.
CREATE VIEW wmsd.available_stock AS
 SELECT b.balance_id, l.warehouse_id, l.location_id, b.lot_id,
        b.qty_base - COALESCE(r.reserved_qty,0) AS available_qty
 FROM wmsd.stock_balance b
 JOIN wmsd.stock_account a ON a.account_id=b.account_id
 JOIN wmsd.location l ON l.location_id=a.location_id
 JOIN wmsd.warehouse w ON w.warehouse_id=l.warehouse_id
 JOIN wmsd.party p ON p.party_id=b.owner_party_id
 JOIN wmsd.lot lot_ref ON lot_ref.lot_id=b.lot_id
 JOIN wmsd.product pr ON pr.product_id=lot_ref.product_id
 LEFT JOIN (SELECT balance_id, SUM(qty_base) AS reserved_qty FROM wmsd.reservation
            WHERE status='ACTIVE' GROUP BY balance_id) r ON r.balance_id=b.balance_id
 WHERE p.party_kind='STORE' AND b.quality_code='GOOD'
   AND lot_ref.identification_status='VERIFIED' AND pr.active = 1
   AND l.active = 1 AND w.active = 1 AND l.allocatable = 1
   AND NOT EXISTS (SELECT 1 FROM wmsd.location_lock k WHERE k.location_id=l.location_id);
GO

COMMIT TRANSACTION;
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
-- 11. Return posting requires the latest assessment for the same return line and
--     document version, CASE_REVIEW eligibility, completed inspection and a matching
--     APPROVE decision/approval_line quantity. Link approval_id to that decision.
--     INELIGIBLE/PENDING assessments cannot authorize GR_CUSTOMER_RETURN; goods
--     physically held remain custody until handback. CASE_REVIEW is not approval.
--     Any condition change creates a new assessment and document version and
--     requires new review; historical assessments/approvals remain immutable.
-- 12. Departmental users record their own operations; no proxy-entry/delegation
--     workflow or purchasing/delivery application role is introduced. Co-inspection
--     and external supplier contacts are recorded in document notes/evidence/audit;
--     those participants do not inherit stock-posting rights.
-- 13. Issue requests reserve availability only; actual handover authorizes PGI.
--     Reconcile MISA order-time records separately from WMS physical dispatches.
--     Monthly stocktake is a planning cadence, not concurrent-movement mode.
-- 14. Preserve actual remaining PIECE quantities for opened/torn boxes. Packaging
--     damage alone must not set DAMAGED quality. Nominal size is not verified calibre.
