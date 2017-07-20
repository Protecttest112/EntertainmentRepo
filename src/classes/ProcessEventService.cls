global class ProcessEventService {
    enum EventType {
        NewApplication, CorruptDocuments, StatusChange, Systemic, DocumentResearch, EDISubmission, EDIFailure, DuplicateSubmission, InvalidSubmission, TwentyOneDayFollowUp
            }
    enum CasePriority {
        Critical, Major, Minor, Warning
            }
    enum MailPriority {
        High, Low, Normal
            }
    
    global class MESSAGE {
        webservice HEADER HEADER;
        webservice MORTGAGEINS_XCM MORTGAGEINS_XCM;
        webservice STATUS STATUS;
    }
    
    global class HEADER {
        webservice HEADER_DETAIL HEADER_DETAIL;
        webservice SERVICE_INFORMATION SERVICE_INFORMATION;
        webservice SOURCE SOURCE;
        webservice DESTINATION DESTINATION;
    }
    
    global class HEADER_DETAIL {
        webservice String MessageIdentifier;
        webservice String MessageTimestamp;
        webservice String ParentTransactionIdentifier;
        webservice String TransactionIdentifier;
    }
    
    global class SERVICE_INFORMATION {
        webservice String Environment;
        webservice String OperationName;
    }
    
    global class SOURCE {
        webservice String ApplicationName;
        webservice String StatusCode;
        webservice String StatusConditionDescription;
        webservice String StatusDescription;
        webservice String StatusName;
    }
    
    global class DESTINATION {
        webservice String ApplicationName;
    }
    
    global class MORTGAGEINS_XCM {
        webservice LOAN LOAN;
        webservice SERVICES SERVICES;
    }
    
    global class LOAN {
        webservice CERTIFICATE CERTIFICATE;
        webservice LOAN_IDENTIFIERS LOAN_IDENTIFIERS;
    }
    
    global class CERTIFICATE {
        webservice CERTIFICATE_DETAIL CERTIFICATE_DETAIL;
        webservice POLICY POLICY;
    }
    
    global class CERTIFICATE_DETAIL {
        webservice String MICertificateIdentifier;
        webservice String PolicyStatusType;
    }
    
    global class POLICY {
        webservice POLICY_DETAIL POLICY_DETAIL;
    }
    
    global class POLICY_DETAIL {
        webservice String MIPolicyNumber;
    }
    
    global class LOAN_IDENTIFIERS {
        webservice LOAN_IDENTIFIER LOAN_IDENTIFIER;
    }
    
    global class LOAN_IDENTIFIER {
        webservice String LoanIdentifier;
        webservice String LoanIdentifierType;
    }
    
    global class SERVICES {
        webservice SERVICE SERVICE;
    }
    
    global class SERVICE {
        webservice RADIAN RADIAN;
    }
    
    global class RADIAN {
        webservice PROCESS_EVENT PROCESS_EVENT;
    }
    
    global class PROCESS_EVENT {
        webservice PROCESS_EVENT_DETAIL PROCESS_EVENT_DETAIL;
    }
    
    global class PROCESS_EVENT_DETAIL {
        webservice String EventType;
        webservice String EventDescription;
        webservice String AccountIdentifier;
        webservice String FirstName;
        webservice String LastName;
        webservice String Email;
        webservice String Phone;
        webservice String ApplicationType;
        webservice CASE_DETAIL CASE_DETAIL;
        webservice EMAIL_DETAIL EMAIL_DETAIL;
    }
    
    global class CASE_DETAIL {
        webservice String CaseKnowledgeBase;
        webservice String CaseMessage;
        webservice String CaseMessageGroup;
        webservice String CaseNodeServerName;
        webservice String CaseObject;
        webservice String CasePolicy;
        webservice String CasePriority;
        webservice String CaseStatistics;
        webservice String CaseCategory;
        webservice String CaseReason;
        webservice String StatusOfCase;
    }
    
    global class EMAIL_DETAIL {
        webservice String FromAddress;
        webservice String ToAddress;
        webservice String CCAddress;
        webservice String BCCAddress;
        webservice String SubjectText;
        webservice String BodyText;
        webservice String IsBodyHtml;
        webservice String MailPriority;
        webservice Boolean IsSecure;
        webservice ATTACHMENTS ATTACHMENTS;
    }
    
    global class ATTACHMENTS {
        webservice List < String > DocumentUUID;
    }
    
    global class STATUS {
        webservice String StatusCode;
        webservice String StatusName;
        webservice String StatusDescription;
        webservice String StatusConditionDescription;
    }
    
    global class RESULT {
        webservice MESSAGE MESSAGE;
    }
    
   
    public static Boolean ValidateInputData(MESSAGE MESSAGE) {
            return false;
        }
    
}