public without sharing class MCPM_WalkSectorsTab_Controller {
    
    public String strJsonRepOptions{ get;set; }
    public String strJsonFSMOptions{ get;set; }
    public String strJsonRSMOptions{ get;set; }
    public String strJsonWalkSector{ get;set; }
    public String strJsonWalkPostcode{ get;set; }
    public String strWalkStartDate{ get;set; }
    public Boolean bIsRSM{ get;set; }
    public Boolean bIsFSM{ get;set; }
    /*NPC:9707*/  
    public static string userId;
    public boolean rsmtoFsmView{get; set;}
    public boolean adminView{get;set;}//NPC:10676
    /*NPC:9707*/ 
    /*NPC:9707*/ 
    public boolean rsmtoRsmView{get; set;}
    public boolean fsmtoFsmView{get; set;}
    public String strJsonFnalRSMOptions{get;set;}
    public String strJsonFnalFSMOptions{get;set;}
    public static String loggedinUser{get;set;}
    /*NPC:9707*/ 
    
    public MCPM_WalkSectorsTab_Controller(){
        
        //strWalkStartDate = MCPM_AppConfig__c.getOrgDefaults().MCPM_Walkcard_Start_Date__c.format('d/M/yyyy');
        userId = userInfo.getUserId();//NPC:9707
        Set<Id> setRSMUserIds = new Set<Id>();
        Set<Id> setFSMUserIds = new Set<Id>();
        Set<Id> setRepUserIds = new Set<Id>();
        Set<Id> setAdminUserIds = new Set<Id>();
        
        bIsRSM = false;
        bIsFSM = false;
        /*NPC:9707*/
        rsmtoFsmView = false;
        rsmtoRsmView = false;//9707
        fsmtoFsmView = false;//9707
        adminView = false;//NPC:10676
        
        if(apexPages.currentPage().getParameters().get('fsmId') != null){
            rsmtoFsmView = true;
            userId = apexPages.currentPage().getParameters().get('fsmId');
            loggedinUser = getUser(userId);
        }
        /*NPC:9707*/
        if(apexPages.currentPage().getParameters().get('fsmId') != null){
            fsmtoFsmView = true;
            userId = apexPages.currentPage().getParameters().get('fsmId');
            loggedinUser = getUser(userId);
        }
        if(apexPages.currentPage().getParameters().get('rsmId') != null){
            rsmtoRsmView = true;
            userId = apexPages.currentPage().getParameters().get('rsmId');
            loggedinUser = getUser(userId);
        }
        /*NPC:9707*/
        if(setRSMUserIds.contains(userId) &&  (rsmtoFsmView == false || rsmtoRsmView == true)) {/*NPC:97071*/
            bIsRSM = true;
            /*NPC:10651*/
            //if(MCPM_SchemaUtil.sObjRunningUser.MCPM_Walk_Start_Date__c != null)
             User loggedInRsm = [select id, MCPM_Walk_Start_Date__c from user where id=:userId limit 1];
                if(loggedInRsm != null && loggedInRsm.MCPM_Walk_Start_Date__c != null){
                    strWalkStartDate = loggedInRsm.MCPM_Walk_Start_Date__c.format('d/M/yyyy');
                }
                //strWalkStartDate = MCPM_SchemaUtil.sObjRunningUser.MCPM_Walk_Start_Date__c.format('d/M/yyyy');
        } else if (setFSMUserIds.contains(userId) || rsmtoFsmView) {
            bIsFSM = true;
            if(rsmtoFsmView){
                User u = [select id,Manager.MCPM_Walk_Start_Date__c from user where id=:userId limit 1];
                if(u != null && u.Manager.MCPM_Walk_Start_Date__c != null){
                    strWalkStartDate = u.Manager.MCPM_Walk_Start_Date__c.format('d/M/yyyy');
                }
            }//else if(MCPM_SchemaUtil.sObjRunningUser.Manager.MCPM_Walk_Start_Date__c != null && rsmtoFsmView == false){
            //    strWalkStartDate = MCPM_SchemaUtil.sObjRunningUser.Manager.MCPM_Walk_Start_Date__c.format('d/M/yyyy');
          //  }
            
        }
        system.debug('bIsRSM ** '+bIsRSM + ' ** bIsFSM '+bIsFSM);
        String strProfile = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;
        /*NPC:10676*/
        if(strProfile == 'System Administrator') {
            adminView = true;
        }
        /*NPC:10676*/
        List<MCPM_Option> lstRSMOption = new List<MCPM_Option>();
        List<MCPM_Option> lstFSMOption = new List<MCPM_Option>();
        List<MCPM_Option> lstRepOption = new List<MCPM_Option>();
        List<MCPM_Option> finalLstRSMOption = new List<MCPM_Option>();
        List<MCPM_Option> finalLstFSMOption = new List<MCPM_Option>();
        
        lstRSMOption.add(new MCPM_Option('--none--', ''));
        lstFSMOption.add(new MCPM_Option('--none--', ''));
        lstRepOption.add(new MCPM_Option('--none--', ''));
        finalLstRSMOption.add(new MCPM_Option('--none--', ''));
        finalLstFSMOption.add(new MCPM_Option('--none--', ''));
        
        MCPM_Walk_Sector__c sObjWalkSector = new MCPM_Walk_Sector__c();
        MCPM_Walk_Postcode__c sObjWalkPostcode = new MCPM_Walk_Postcode__c();

        if(strProfile == 'System Administrator' || setAdminUserIds.contains(userId)) {//NPC:9707

            for(User sObjUser: [Select Id, Name from User where Id IN :setRSMUserIds order by Name])
                lstRSMOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id));
                
                for(User sObjUser: [Select Id, Name from User where Id IN :setFSMUserIds order by Name])
                lstFSMOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id));

            for(User sObjUser: [Select Id, Name, SmallPhotoUrl from User where Id IN :setRepUserIds AND IsActive = true order by Name])
                lstRepOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id, sObjUser.Name, sObjUser.SmallPhotoUrl));

            bIsRSM = false;
            bIsFSM = false;
            
        } else {
            if(bIsRSM) {
                Set<Id> setLessFSMUserIds = new Set<Id>();
                /*NPC:10345*/
                set<Id> rsmIdsToShareFsm = new set<Id>();
                User currRsmUser = [select Id, MCPM_Special_RSM__c from User where Id =: userId ];
                
                /*NPC:9707*/
                for(User sObjUser: [Select Id, Name from User where Id  IN :setRSMUserIds order by Name])
                finalLstRSMOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id));          
                /*NPC:9707*/
               
                /*NPC:10345*/
                if(currRsmUser.MCPM_Special_RSM__c == true ){
                   List<User> lRsmSharigUser = [Select Id, username, MCPM_Special_RSM__c  from User where MCPM_Special_RSM__c =: true];
                   if(lRsmSharigUser != null && !lRsmSharigUser.isEmpty()){
                       for(User currRsmSharingUser : lRsmSharigUser ){
                           rsmIdsToShareFsm.add(currRsmSharingUser.Id);
                       }
                   }
                    
                   for(User sObjUser: [Select Id, Name from User where ManagerId IN : rsmIdsToShareFsm AND Id IN :setFSMUserIds AND IsActive = true order by Name]){
                       lstFSMOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id));
                       setLessFSMUserIds.add(sObjUser.Id);
                   }
               }
                
                /*NPC:10345*/
                else{
                    for(User sObjUser: [Select Id, Name from User where ManagerId= :userId AND Id IN :setFSMUserIds AND IsActive = true order by Name]){
                        lstFSMOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id));
                        setLessFSMUserIds.add(sObjUser.Id);
                    }
                }         
                for(User sObjUser: [Select Id, Name from User where ManagerId IN :setLessFSMUserIds AND Id IN :setRepUserIds AND IsActive = true order by Name]){
                    lstRepOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id));
                }
                    
                sObjWalkSector.OwnerId = userId;
            
            } else if(bIsFSM) {
                /*NPC:9707*/
                for(User sObjUser: [Select Id, Name from User where Id  IN :setFSMUserIds order by Name])
                    finalLstFSMOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id));  
                /*NPC:9707*/
                for(User sObjUser: [Select Id, Name, SmallPhotoUrl from User where ManagerId= :userId AND ID IN :setRepUserIds AND IsActive = true order by Name]){
                    lstRepOption.add(new MCPM_Option(sObjUser.Name, sObjUser.Id, sObjUser.Name, sObjUser.SmallPhotoUrl));
                }
            }
        }
        
        strJsonRSMOptions = JSON.serialize(lstRSMOption);
        strJsonFSMOptions = JSON.serialize(lstFSMOption);
        strJsonRepOptions = JSON.serialize(lstRepOption);
        strJsonFnalRSMOptions = JSON.serialize(finalLstRSMOption); /*NPC:9707*/
        strJsonFnalFSMOptions = JSON.serialize(finalLstFSMOption);/*NPC:9707*/
        
        strJsonWalkSector = JSON.serialize(sObjWalkSector);
        strJsonWalkPostcode = JSON.serialize(sObjWalkPostcode);
    }
    /*NPC:9707*/    
    public static String getUser(String strUserId){
    
        User userObj = [SELECT Name FROM User WHERE Id = :strUserId];
        loggedinUser = userObj.Name;
        return loggedinUser;
    }
    /*NPC:9707*/
    @RemoteAction
    public static List<MCPM_Walk_Sector__c> walksectors(String strSearchTxt, String strShow,string fsmuserId,String rsmuserId){
        
        if(fsmuserId == null || fsmuserId == ''){
            fsmuserId = userInfo.getUserId();
        }
        /*NPC:9707*/
        if(rsmuserId == null || rsmuserId == ''){
            rsmuserId = userInfo.getUserId();
        }
        /*NPC:9707*/
        String strQuery = 'Select Id, Name, Owner.Id, Owner.Name, MCPM_Number_Of_Premises__c, MCPM_Active_Premises__c,  MCPM_FSM__r.Id, MCPM_FSM__r.Name, MCPM_Walk_Sector_Sort__c, ' +
                          'MCPM_Current_State__c, MCPM_Future_State__c, MCPM_Current_Rep__r.Id, MCPM_Current_Rep__r.Name, MCPM_Future_Rep__r.Id, MCPM_Future_Rep__r.Name ' +
                          'from MCPM_Walk_Sector__c where ';
                          
        if (strShow == 'Current')
            strQuery += 'MCPM_Current_State__c = true and ';
        else if (strShow == 'Future')
            strQuery += 'MCPM_Future_State__c = true and ';
        
        String strProfile = [Select Name from Profile where Id = :UserInfo.getProfileId()].Name;

        if(strProfile != 'System Administrator') {
            Set<Id> setFSMUserIds = new Set<Id>();
            Set<Id> setRSMUserIds = new Set<Id>();
            if(setFSMUserIds.contains(fsmuserId)){
                strQuery += 'MCPM_FSM__c = \''+fsmuserId+'\' and ';
                strQuery += '(MCPM_Current_State__c = true OR MCPM_Future_State__c = true) and ';
            }
            /*NPC:9707*/
            if(setRSMUserIds.contains(rsmuserId)){
                 strQuery += 'OwnerId = \'' + rsmuserId + '\' and ';
            }/*NPC:9707*/
        }

        if(String.isBlank(strSearchTxt)) {
            strQuery = strQuery.removeEnd('where ');
            strQuery = strQuery.removeEnd('and ');
            strQuery += 'Order By MCPM_Walk_Sector_Sort__c Limit 500';
        } else {
            strQuery += 'Name Like \'' + String.escapeSingleQuotes(strSearchTxt) + '%\' Order By MCPM_Walk_Sector_Sort__c Limit 500';
        }
        return Database.query(strQuery);
        
    }
    
   /* @RemoteAction
    public static MCPM_Walk_Sector__c save(MCPM_Walk_Sector__c sObjWalkSector){
        
        update sObjWalkSector;
        
        return [Select  Id, Name, Owner.Id, Owner.Name, MCPM_Number_Of_Premises__c, MCPM_Active_Premises__c, MCPM_FSM__r.Id, MCPM_FSM__r.Name, MCPM_Walk_Sector_Sort__c, 
                        MCPM_Current_State__c, MCPM_Future_State__c, MCPM_Current_Rep__r.Id, MCPM_Current_Rep__r.Name, MCPM_Future_Rep__r.Id, 
                        MCPM_Future_Rep__r.Name from MCPM_Walk_Sector__c where Id = :sObjWalkSector.Id];
    }
	
    @RemoteAction
    public static Boolean startNextPeriod(String rsmuserId){
        /*NPC:10651
        String currUserId;
            
        if(String.isNotBlank(rsmuserId)){
            currUserId = rsmuserId;
        }
        else{
            currUserId = UserInfo.getUserId();
        }
        
        List<MCPM_Walk_Sector__c> lstWalkSector =[Select Id, MCPM_Current_State__c, MCPM_Future_State__c from MCPM_Walk_Sector__c 
                                                            where OwnerId = :currUserId AND 
                                                            (MCPM_Current_State__c = true OR MCPM_Future_State__c = true)];                                                  
         
        if(!lstWalkSector.isEmpty()){
            for(MCPM_Walk_Sector__c sObjWalkSector: lstWalkSector) {
                
                if(sObjWalkSector.MCPM_Future_State__c) {
                    sObjWalkSector.MCPM_Current_State__c = true;
                    sObjWalkSector.MCPM_Future_State__c = false;
                } else
                    sObjWalkSector.MCPM_Current_State__c = false;
            }
        }
        
        if(!lstWalkSector.isEmpty() && !Test.isRunningTest()) {
            
            Database.executeBatch(new MCPM_StartNextPeriodBatch(lstWalkSector), 10);
            /*NPC:10651
            MCPM_UserHelper.resetDaysWorked(currUserId);
        } else
            return false;

        //update lstWalkSector;
        //MCPM_AppConfig__c sObjAppConfig = MCPM_AppConfig__c.getOrgDefaults();
        //sObjAppConfig.MCPM_Walkcard_Start_Date__c = System.now();
        //update sObjAppConfig;
        
        return true;
    }
    */
    @RemoteAction
    public static String saveWalkSector(MCPM_Walk_Sector__c sobjWalkSector){
        
        try {
            insert sobjWalkSector;
        } catch (DMLException e){
            if(e.getDMLType(0)==System.StatusCode.DUPLICATE_VALUE &&  e.getDMLMessage(0).indexOf('MCPM_Walk_Sector_Sort__c')!=-1){
                return System.label.MCPM_WalkSectorExistsMsg;
            }
            return e.getDmlMessage(0);
        }
        return sobjWalkSector.Id;
    }
    
    @RemoteAction /*P7082906*/
    public static List<MCPM_Walk_Postcode__c> walkpostcodeData(String strSearchTxt, List<Id> lstSectorIds, Boolean bIsRSM, String fsmId){
        
        String strQuery = 'Select Id, Name, MCPM_Number_Of_Premises__c, MCPM_Active_Premises__c, MCPM_Walk_Sector__r.Name, Owner.Id, Owner.Name, MCPM_Rep__r.Id, MCPM_Rep__r.Name, MCPM_Postcode_Sort__c, ' +
                          'MCPM_Current_State__c, MCPM_Future_State__c, MCPM_Future_Rep__r.Id, MCPM_Future_Rep__r.Name from MCPM_Walk_Postcode__c where MCPM_Walk_Sector__c IN :lstSectorIds AND ';
        
        //if (strShow == 'Current')
        //    strQuery += 'MCPM_Current_State__c = true and MCPM_Is_Walk_Sector_Assigned__c = true and ';
        //else if (strShow == 'Future')
        //    strQuery += 'MCPM_Future_State__c = true and MCPM_Is_Walk_Sector_Assigned__c = true and ';
        //else
        //    strQuery += '(MCPM_Current_State__c = true OR MCPM_Future_State__c = true) and MCPM_Is_Walk_Sector_Assigned__c = true and ';
        
        strQuery += '(MCPM_Current_State__c = true OR MCPM_Future_State__c = true) and MCPM_Is_Walk_Sector_Assigned__c = true and ';
        
              /*P7082906*/
            if(fsmId == null || fsmId == ''){
                if(bIsRSM)
                    strQuery += 'MCPM_Walk_Sector__r.OwnerId = \'' + UserInfo.getUserId() + '\' and ';
                else 
                    strQuery += 'OwnerId = \'' + UserInfo.getUserId() + '\' and ';
                
                }
            else{
                strQuery += 'OwnerId = \'' + fsmId + '\' and ';
            }   

        if(String.isBlank(strSearchTxt)) {
            strQuery = strQuery.removeEnd('and ');
            strQuery += 'Order By MCPM_Postcode_Sort__c Limit 500';
        } else {
            strQuery += 'Name Like \'' + String.escapeSingleQuotes(strSearchTxt) + '%\' Order By MCPM_Postcode_Sort__c Limit 500';
        }
        
        return Database.query(strQuery);
    }
    
  /*  @RemoteAction
    public static MCPM_Walk_Postcode__c savePostcode(MCPM_Walk_Postcode__c sObjWalkPostcode){
        
        update sObjWalkPostcode;
        
        return [Select  Id, Name, MCPM_Number_Of_Premises__c, MCPM_Active_Premises__c, MCPM_Walk_Sector__r.Name, Owner.Id, Owner.Name, MCPM_Rep__r.Id, MCPM_Rep__r.Name, 
                        MCPM_Current_State__c, MCPM_Future_State__c, MCPM_Future_Rep__r.Id, MCPM_Future_Rep__r.Name from MCPM_Walk_Postcode__c where Id = :sObjWalkPostcode.Id];
    }
    */
    @RemoteAction  /*P7082906*/
    public static List<MCPM_Walk_Postcode__c> autoAssign(List<MCPM_Option> lstRep, List<Id> lstSectorIds, String fsmid){
        /*P7120650*/
     //   doAutoAssignments(lstRep, lstSectorIds, fsmid);
        /*P7120650*/
        return walkpostcodeData('', lstSectorIds, false, fsmid);
    }
    /*
    private static void doAutoAssignments(List<MCPM_Option> lstRep, List<Id> lstSectorIds, String fsmid){
        /*P7120650
        String currUserId;
        if(String.isNotBlank(fsmid)){
            currUserId = fsmid;
        }else{
            currUserId = UserInfo.getUserId();
        }
        
        List<MCPM_Walk_Postcode__c> lstWPostcode;
        
        if(lstSectorIds != null && !lstSectorIds.isEmpty()) {
            lstWPostcode = [Select  Id, Name, MCPM_Number_Of_Premises__c, MCPM_Active_Premises__c from MCPM_Walk_Postcode__c 
                                    where MCPM_Walk_Sector__c IN :lstSectorIds AND OwnerId = :currUserId AND  
                                    MCPM_Future_State__c = true Order By MCPM_Postcode_Sort__c];
        } else {
            lstWPostcode = [Select  Id, Name, MCPM_Number_Of_Premises__c, MCPM_Active_Premises__c from MCPM_Walk_Postcode__c 
                                    where OwnerId = :currUserId AND MCPM_Future_State__c = true 
                                    Order By MCPM_Postcode_Sort__c];
        }
        
        if(!lstWPostcode.isEmpty()){
            List<Integer> lstPremiseCount = new List<Integer>();
            Integer intTotal = 0;
            
            for(MCPM_Walk_Postcode__c sObjWPostcode: lstWPostcode){
                Integer intCount = Integer.valueOf(sObjWPostcode.MCPM_Number_Of_Premises__c);
                lstPremiseCount.add(intCount);
                intTotal += intCount;
            }
            
            Integer intAvgPremisePerAgent = Integer.valueOf(intTotal / lstRep.size());
            Integer intStdDeviation = Integer.valueOf(MCPM_Util.standardDeviation(lstPremiseCount, MCPM_Util.mean(lstPremiseCount)));
            Integer intMinThreshold = intAvgPremisePerAgent - intStdDeviation;
            Integer intMaxThreshold = intAvgPremisePerAgent + intStdDeviation;
            Integer intMaxIndex = lstRep.size() - 1;
            Integer intRepIndex = 0;
            intTotal = 0;
            
            for(MCPM_Walk_Postcode__c sObjWPostcode: lstWPostcode){
                Integer intCount = Integer.valueOf(sObjWPostcode.MCPM_Number_Of_Premises__c);
                if((intTotal >= intMinThreshold ||(intTotal + intCount) >= intMaxThreshold) && intRepIndex !=intMaxIndex){
                    intRepIndex ++;
                    intTotal = 0;
                }
                sObjWPostcode.MCPM_Future_Rep__c = lstRep[intRepIndex].key;
                intTotal += intCount;
            }
            update lstWPostcode;
        }
    }
    */
    @RemoteAction
    public static List<MCPM_Option> assignmentInfo(Boolean bCurrent, List<Id> lstSectorIds, Boolean bIsRSM){
        
        List<MCPM_Option> lstAgents = new List<MCPM_Option>();
        Map<String, String> mapPostcodes = new Map<String, String>();
        
        String strQuery;
        
        if(bCurrent){
            strQuery = 'Select count(Id), MCPM_Rep__c agentId from MCPM_Walk_Postcode__c where ';
            if(lstSectorIds != null && !lstSectorIds.isEmpty())
                strQuery += 'MCPM_Walk_Sector__c IN :lstSectorIds AND ';
                if(bIsRSM)
                    strQuery += 'MCPM_Walk_Sector__r.OwnerId = \'' + UserInfo.getUserId() + '\' and ';
                else
                    strQuery += 'OwnerId = \'' + UserInfo.getUserId() + '\' and ';
            strQuery += 'MCPM_Rep__c != null AND MCPM_Current_State__c = true ';
            strQuery += 'group by MCPM_Rep__c';
        } else {
            strQuery = 'Select count(Id), MCPM_Future_Rep__c agentId from MCPM_Walk_Postcode__c where ';
            if(lstSectorIds != null && !lstSectorIds.isEmpty())
                strQuery += 'MCPM_Walk_Sector__c IN :lstSectorIds AND ';
                if(bIsRSM)
                    strQuery += 'MCPM_Walk_Sector__r.OwnerId = \'' + UserInfo.getUserId() + '\' and ';
                else
                    strQuery += 'OwnerId = \'' + UserInfo.getUserId() + '\' and ';
            strQuery += 'MCPM_Future_Rep__c != null AND MCPM_Future_State__c = true ';
            strQuery += 'group by MCPM_Future_Rep__c';
        }
                    
        for(AggregateResult aggResult: Database.query(strQuery)){
            mapPostcodes.put(String.valueOf(aggResult.get('agentId')), String.valueOf(aggResult.get('expr0')));
        }
        
        Map<String, String> mapPremise = new Map<String, String>();
        
        if(bCurrent){
            strQuery = 'Select Sum(MCPM_Number_Of_Premises__c), SUM(MCPM_Active_Premises__c), MCPM_Rep__c agentId from MCPM_Walk_Postcode__c where ';
            if(lstSectorIds != null && !lstSectorIds.isEmpty())
                strQuery += 'MCPM_Walk_Sector__c IN :lstSectorIds AND ';
                if(bIsRSM)
                    strQuery += 'MCPM_Walk_Sector__r.OwnerId = \'' + UserInfo.getUserId() + '\' and ';
                else
                    strQuery += 'OwnerId = \'' + UserInfo.getUserId() + '\' and ';
            strQuery += 'MCPM_Rep__c != null AND MCPM_Current_State__c = true ';
            strQuery += 'group by MCPM_Rep__c';
        } else {
            strQuery = 'Select Sum(MCPM_Number_Of_Premises__c), SUM(MCPM_Active_Premises__c), MCPM_Future_Rep__c agentId from MCPM_Walk_Postcode__c where ';
            if(lstSectorIds != null && !lstSectorIds.isEmpty())
                strQuery += 'MCPM_Walk_Sector__c IN :lstSectorIds AND ';
                if(bIsRSM)
                    strQuery += 'MCPM_Walk_Sector__r.OwnerId = \'' + UserInfo.getUserId() + '\' and ';
                else
                    strQuery += 'OwnerId = \'' + UserInfo.getUserId() + '\' and ';
            strQuery += 'MCPM_Future_Rep__c != null AND MCPM_Future_State__c = true ';
            strQuery += 'group by MCPM_Future_Rep__c';
        }
        
        for(AggregateResult aggResult: Database.query(strQuery)){
            mapPremise.put(String.valueOf(aggResult.get('agentId')), '' + Integer.valueOf(aggResult.get('expr0')));
        }
        
        for(User u:[Select Id, Name, SmallPhotoUrl from User where Id IN : mapPostcodes.keySet() Order By Name]){
            lstAgents.add(new MCPM_Option(u.Name, mapPremise.get(u.Id), mapPostcodes.get(u.Id), u.SmallPhotoUrl));
        }
        return lstAgents;
    }
    /*
    @RemoteAction
    public static String saveWalkPostcode(MCPM_Walk_Postcode__c sobjWalkPostcode){
        
        String strWalkSector;
        try {
            strWalkSector = sobjWalkPostcode.Name.subString(0, (sobjWalkPostcode.Name.length()-2));
            MCPM_Walk_Sector__c sobjWalkSector = [Select Id, MCPM_FSM__c from MCPM_Walk_Sector__c where Name = :strWalkSector];
            sobjWalkPostcode.MCPM_Walk_Sector__c = sobjWalkSector.Id;
            
            if(String.isBlank(sobjWalkPostcode.OwnerID)) {
                sobjWalkPostcode.OwnerID = UserInfo.getUserId();
                if(sobjWalkSector.MCPM_FSM__c != sobjWalkPostcode.OwnerID)
                    return 'You cannot create postcodes outside sectors assigned to you.';
            }
        } catch (Exception e){
            return 'No walk sector found by name: '+strWalkSector;
        }
        
        try {
            insert sobjWalkPostcode;
        } catch (DMLException e){
            if(e.getDMLType(0)==System.StatusCode.DUPLICATE_VALUE &&  e.getDMLMessage(0).indexOf('MCPM_Postcode_Sort__c')!=-1){
                return System.label.MCPM_WalkPostcodeExistsMsg;
            }
            return e.getDmlMessage(0);
        }
        return sobjWalkPostcode.Id;
    }
    */
    @RemoteAction
    public static void savePostcodes(List<MCPM_Walk_Postcode__c> lstWalkPostcode){
        update lstWalkPostcode;
    }
}