SET @row_number = 0;
SELECT
(@row_number:=@row_number + 1) AS NAMBA,
v.date_started AS `TAREHE YA MAHUDHURIO`,
CONCAT(pn.given_name,' ',pn.family_name) AS `JINA LA MGONJWA`,
pa.address1 AS `MAHALI ANAISHI`,
GROUP_CONCAT(DISTINCT CASE WHEN p.gender='M' THEN 'Me'  ELSE 'Ke' END) AS `JINSIA YA MGONJWA`,
DATE_FORMAT(FROM_DAYS(DATEDIFF(v.date_started, p.birthdate)), '%Y') + 0 AS UMRI,
-- GROUP_CONCAT(DISTINCT CASE WHEN ob.concept_id=165861 THEN ob.value_numeric  ELSE null END) AS `UZITO`,
-- GROUP_CONCAT(DISTINCT CASE WHEN ob.concept_id=165860 THEN ob.value_numeric  ELSE null END) AS `UREFU`,
GROUP_CONCAT(DISTINCT CASE WHEN ed.certainty='CONFIRMED' THEN diagnosis_concept_name.name ELSE NULL END) AS `DALILI ZA ZIADA`,
GROUP_CONCAT(DISTINCT d.name) AS `DAWA ANAZOONDOKA NAZO`,
GROUP_CONCAT(v.date_stopped) AS `MUDA WA KUKAA DTC`


FROM visit v

-- Addressing names and address
LEFT JOIN person p ON p.person_id=v.patient_id
LEFT JOIN person_name pn ON p.person_id=pn.person_id
LEFT JOIN person_address pa ON p.person_id=pa.person_id

-- Addressing Diagnosis
LEFT JOIN encounter diagnosis_encounter ON diagnosis_encounter.visit_id=v.visit_id
LEFT JOIN encounter_diagnosis ed ON ed.encounter_id=diagnosis_encounter.encounter_id
LEFT JOIN concept diagnosis_concept ON ed.diagnosis_coded=diagnosis_concept.concept_id
LEFT JOIN concept_name diagnosis_concept_name ON diagnosis_concept_name.concept_id=diagnosis_concept.concept_id



-- Addressing Matibabu
LEFT JOIN encounter drug_order_encounter ON drug_order_encounter.visit_id=v.visit_id
LEFT JOIN orders drug_order_order ON drug_order_order.encounter_id=drug_order_encounter.encounter_id
LEFT JOIN order_type drug_order_order_type ON drug_order_order_type.order_type_id=drug_order_order.order_type_id AND drug_order_order_type.name ='Drug Order'
LEFT JOIN drug_order do ON do.order_id=drug_order_order.order_id
LEFT JOIN drug d ON d.drug_id=do.drug_inventory_id


GROUP BY v.visit_id,CONCAT(pn.given_name,' ',pn.family_name),pa.address1