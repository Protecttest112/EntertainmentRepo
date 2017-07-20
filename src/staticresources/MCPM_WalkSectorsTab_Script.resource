//creating angular app 'Walksectors'
angular.module('walksectors', ['ui.bootstrap', 'ui.sortable'])
//creating a filter that finds index in a list of array
.filter('findIndex', function() {
    return function(sectors, name) {
        var index = 0;
        var returnIndex = null;
        angular.forEach(sectors, function(e){
            if (e.Name == name) {
                returnIndex = index;
            }
            index++;
        });
        return returnIndex;
    };
})
//creating a filter that reutrns true if element is present in a list of array
.filter('contains', function() {
    return function(sectors, name) {
        var flag = false;
        angular.forEach(sectors, function(e){
            if (e.Name == name) {
                flag = true;
            }
        });
        return flag;
    };
})
//creating a filter that adds element to a list, behaves like a set
.filter('addAll', function($filter) {
    return function(selected, sectors) {
        var flag = true;
        angular.forEach(selected, function(e){
            if(!$filter('contains')(sectors, e.Name)) {
                sectors.push(e);
                e.select = true;
            }
        });
        return flag;
    };
})
//creating a filter that removes list of elemets from a list of array
.filter('removeAll', function($filter) {
    return function(selected, sectors) {
        var flag = true;
        var index;
        angular.forEach(selected, function(e){
            index = $filter('findIndex')(sectors, e.Name);
            if(index !== null) {
                sectors.splice(index, 1);
                e.select = false;
            }
        });
        return flag;
    };
})
//controller for app 'walksectors'
.controller('walksectors-ctrl',function($scope, $q, $filter){
	
	//initializing items
	$scope.itemsPerPage = 15;
	$scope.walkStartDate = strWalkStartDate;
	
	$scope.rsmOptions = rsmOptions;
	$scope.fsmOptions = fsmOptions;
	$scope.repOptions = repOptions;
	$scope.newRsmOptions = newRsmOptions;
	$scope.newFsmOptions = newFsmOptions;
	
	$scope.showAssignments = 'current';
	$scope.showCurrent = true;
	$scope.isRSM = isRSM;
	$scope.isFSM = isFSM;
	
	$scope.selectedSectors = [];
	
	angular.forEach($scope.repOptions, function(e){
        if(e.key !== '')
			tmpList.push({
				value: e.value,
				key: e.key,
				imgUrl: e.imgUrl,
				checked: false
			});
	});
	
	$scope.list = tmpList;
	
	//selection method for walk sectors
	$scope.select = function(index) {
	    var begin = (($scope.currentPage - 1) * $scope.itemsPerPage);
	    index = index + begin;
	    var selectedSector = $scope.walksectorData[index];
	    if(selectedSector.select)
	        $scope.selectedSectors.push(selectedSector);
	    else {
	        var i = $filter('findIndex')($scope.selectedSectors, selectedSector.Name);
	        $scope.selectedSectors.splice(i, 1);
	    }
	};
	
	//select all action at the table header
	$scope.selectAction = function() {
	    if($scope.selectAll){
	        $filter('addAll')($scope.filteredWalksectorData, $scope.selectedSectors);
	    } else {
            $filter('removeAll')($scope.filteredWalksectorData, $scope.selectedSectors);
	    }
	};
	
	//opening up update FSM model
	$scope.reassignFSM = function() {
	    $scope.selectedFSM = '';
	    $scope.total = $scope.selectedSectors.length;
	    $scope.current = 0;
	    $scope.dynamic = 0;
	    j$('#reassignFSMModal').modal('show');
	};
	
	//save action from update FSM model
	$scope.saveAssignment = function() {
	    j$('#reassignFSMModal').modal('hide');
	    j$('#progressModal').modal('show');
	    $scope.alerts = [];
	    $scope.updateType = "FSM";
	    $scope.handleUpdates();
	};
	
	//save action from update FSM model
	<!--NPC-9707--> 
	$scope.reassignFSMView = function() {
	    $scope.selectedFSMId = '';
	    $scope.total = $scope.selectedSectors.length;
	    $scope.current = 0;
	    $scope.dynamic = 0;
	    j$('#reassignFSMModalBox').modal('show');
	};

	$scope.changeAssignment = function(selectedFSMId) {
		window.location.assign("/apex/MCPM_WalkSectorsTab?fsmId="+$scope.selectedFSMId)
	    //j$('#reassignFSMModalBox').modal('hide');
	};
	<!-- NPC:9707 -->
	<!-- NPC:9707 -->
	$scope.reassignRSMView = function() {
	    $scope.selectedRSMId = '';
	    $scope.total = $scope.selectedSectors.length;
	    $scope.current = 0;
	    $scope.dynamic = 0;
	    j$('#reassignRSMModalBox').modal('show');
	};

	$scope.changeRsmAssignment = function(selectedRSMId) {
		window.location.assign("/apex/MCPM_WalkSectorsTab?rsmId="+$scope.selectedRSMId)
	    //j$('#reassignFSMModalBox').modal('hide');
	};
	
	$scope.switchToFSMView = function() {
	    $scope.checkedFSMId = '';
	    $scope.total = $scope.selectedSectors.length;
	    $scope.current = 0;
	    $scope.dynamic = 0;
	    j$('#changeFSMModalBox').modal('show');
	};

	$scope.changeFSMAssignment = function(checkedFSMId) {
		window.location.assign("/apex/MCPM_WalkSectorsTab?fsmId="+$scope.checkedFSMId)
	    //j$('#reassignFSMModalBox').modal('hide');
	};
	<!-- NPC:9707 -->
	
	$scope.startNextModal = function() {
	    $scope.collapseInput = false;
	    $scope.dialogAlerts = [];
	    j$('#startNextModal').modal('show');
	};
	
	//opening up update rep model (current and future)
	$scope.reassignRep = function(current) {
	   
	    $scope.collapseInput = false;
	    $scope.assigningCurrent = current;
	    $scope.selectedRep = '';
	    $scope.isFromSector = true;
	    $scope.isFromPostcode = false;
	    $scope.total = $scope.selectedSectors.length;
	    $scope.current = 0;
	    $scope.dynamic = 0;
	    j$('#reassignRepModal').modal('show');
	};
	
	//save action from update rep model
	$scope.saveRepAssignment = function() {
	    
	    j$('#reassignRepModal').modal('hide');
	    j$('#progressModal').modal('show');
	    $scope.alerts = [];
	    if($scope.assigningCurrent)
	        $scope.updateType = "CurrentRep";
	    else
	        $scope.updateType = "FutureRep";
	    $scope.handleUpdates();
	};
	
	//handle updates in chunks of 1 from mass update dialogs
	$scope.handleUpdates = function() {
	    
	    if($scope.selectedSectors.length === 0) {
	        j$('#progressModal').modal('hide');
	        $scope.walksector();
	    } else {
	        var update = angular.copy($scope.selectedSectors[0]);
	        if($scope.updateType == "FSM")
    		    update.MCPM_FSM__c = $scope.selectedFSM;
    		else if($scope.updateType == "CurrentRep")
    		    update.MCPM_Current_Rep__c = $scope.selectedRep;
    		else if($scope.updateType == "FutureRep")
    		    update.MCPM_Future_Rep__c = $scope.selectedRep;
    		
    		delete update.MCPM_FSM__r;
    		delete update.fade;
    		delete update.Owner;
    		delete update.select;
    		
    		saveR(update, function(result, event){  
    			$scope.$apply(function(){  
    			    $scope.current++;
    			    $scope.dynamic = ($scope.current * 100 )/$scope.total;
    				if(event.status) {
    					$scope.selectedSectors.splice(0, 1);
    					$scope.handleUpdates();
    				} else {
    					$scope.alerts.push({type: 'danger', msg: event.message});
    					$scope.selectedSectors.splice(0, 1);
    					$scope.handleUpdates();
    				}
    			});   
    		});
	    }
	};

	//getting walksector data from salesforce database based on user interactions
	$scope.walksector = function() {
		
		if($scope.showCurrent)
            $scope.show = "Current";
		else if($scope.showFuture)
            $scope.show = "Future";
		else
            $scope.show = "All";
		
		$scope.loaded = false;
		$scope.alerts = null;
		$scope.walksectorData = null;
		walksectorDataR($scope.searchText, $scope.show, function(result, event){  
			$scope.$apply(function(){
				if(event.status) {
					$scope.sort = "MCPM_Walk_Sector_Sort__c";
					$scope.reverse = false;
					$scope.walksectorData = result;
					angular.forEach($scope.walksectorData, function(e){
						if(!e.MCPM_FSM__c)
							e.MCPM_FSM__c = '';
						if(!e.MCPM_Current_Rep__c)
							e.MCPM_Current_Rep__c = '';
						if(!e.MCPM_Future_Rep__c)
							e.MCPM_Future_Rep__c = '';
						if(!e.MCPM_Active_Premises__c)<!--NPC-9707--> 
							e.MCPM_Active_Premises__c = 0;
						if($filter('contains')($scope.selectedSectors, e.Name)){
						    e.select = true;
						}
					});
					$scope.totalItems = $scope.walksectorData.length;
					$scope.currentPage = 1;
					$scope.$watch('currentPage + itemsPerPage', $scope.paginate);
					$scope.loaded = true;
				} else {
					$scope.alerts = [{type: 'danger', msg: event.message}];
				}
			});   
		});
	};
	
	//setting up initial set of walk sector data on tab
	$scope.searchText = "";
	$scope.searchTextPostcode = '';
	$scope.showCurrent = true;
	$scope.walksector();
	
	//saving chnages made at the row level
	$scope.save = function(value){
		
		var row = $scope.filteredWalksectorData[value];
		row.fade = true;
		$scope.alerts = null;
		var update = angular.copy($scope.filteredWalksectorData[value]);
		
		delete update.MCPM_FSM__r;
		delete update.fade;
		delete update.Owner;
		delete update.select;
		
		saveR(update, function(result, event){  
			$scope.$apply(function(){  
				
				if(event.status) {
					if(!result.MCPM_FSM__c)
						result.MCPM_FSM__c = '';
					if(!result.MCPM_Current_Rep__c)
						result.MCPM_Current_Rep__c = '';
					if(!result.MCPM_Future_Rep__c)
						result.MCPM_Future_Rep__c = '';
					if($filter('contains')($scope.selectedSectors, result.Name))
					    result.select = true;
					$scope.filteredWalksectorData[value] = result;
					$scope.walksectorData[$scope.itemsPerPage * ($scope.currentPage - 1) + value] = result;
					row.fade = false;
				} else {
				    row.fade = false;
					$scope.alerts = [{type: 'danger', msg: event.message}];
				}
			});   
		});
	};
	
	//start next period action
	$scope.startNextPeriod = function(){
	    
		startNextPeriodR(function(result, event){  
			$scope.$apply(function(){  
			    $scope.collapseInput = true;
				if(event.status) {
				    if(result)
				        $scope.dialogAlerts = [{type: 'success', msg: 'We are processing your request, you will be notified shortly.'}];
				    else
				        $scope.dialogAlerts = [{type: 'danger', msg: 'Sorry! we can\'t process your request, no sectors to activate or deactivate.'}];
				} else {
					$scope.dialogAlerts = [{type: 'danger', msg: event.message}];
				}
			});   
		});
	};
	
	//paginate method for walk sectors
	$scope.paginate = function() {
		var begin = (($scope.currentPage - 1) * $scope.itemsPerPage),
		end = begin + $scope.itemsPerPage;
		$scope.filteredWalksectorData = $scope.walksectorData.slice(begin, end);
		$scope.selectAll = false;
	};
	
	//chnage sort options on walk sectors
	$scope.changeSort = function(value){
		
		if ($scope.sort == value){
            $scope.reverse = !$scope.reverse;
            $scope.walksectorData = $filter('orderBy')($scope.walksectorData, $scope.sort, $scope.reverse);
            $scope.paginate();
            $scope.currentPage = 1;
            return;
		}
		
		$scope.sort = value;
		$scope.reverse = false;
		
		$scope.walksectorData = $filter('orderBy')($scope.walksectorData, $scope.sort, $scope.reverse);
		$scope.paginate();
		$scope.currentPage = 1;
	};
	
	//open add new sector dialog
	$scope.addNew = function(){
        
        j$('#addNewModal').modal('show');
        $scope.collapseInput = false;
        $scope.dialogAlerts = null;
        $scope.newWalkSector = angular.copy(masterWalkSector);
        $scope.newWalkSector.Name = '';
        if(!$scope.newWalkSector.OwnerId)
            $scope.newWalkSector.OwnerId = '';
        $scope.newWalkSector.MCPM_FSM__c = '';
	};
	
	//save a new Walk sector
	$scope.saveWalkSector = function(){
        
        j$('#saveWalkSector').button('loading');
		$scope.dialogAlerts = null;
        var insert = angular.copy($scope.newWalkSector);
		delete insert.attributes;
		
		saveWalkSectorR(insert, function(result, event){  
			$scope.$apply(function(){  
				if(event.status) {
                    if(result.length==18) {
                        $scope.collapseInput = true;
                        j$('#saveWalkSector').button('reset');
                        $scope.dialogAlerts = [{type: 'success', msg: 'You successfully created a walksector.'}];
                    } else {
                        $scope.dialogAlerts = [{type: 'danger', msg: result}];
                        j$('#saveWalkSector').button('reset');
                    }
				} else {
					$scope.dialogAlerts = [{type: 'danger', msg: event.message}];
					j$('#saveWalkSector').button('reset');
				}
			});
		});
	};
	
	//getting walkpostcode data from salesforce database based on user interactions
	$scope.walkpostcode = function(){
        
        if($scope.showCurrent)
            $scope.show = "Current";
		else if($scope.showFuture)
            $scope.show = "Future";
		else
            $scope.show = "All";
		
		$scope.loadedPostcode = false;
		$scope.alertsPostcode = null;
		$scope.walkpostcodeData = null;
		
		walkpostcodeR($scope.searchTextPostcode, $scope.selectedSectorIds, $scope.isRSM, function(result, event){  
			$scope.$apply(function(){  
				if(event.status) {
					$scope.sortPostcode = "MCPM_Postcode_Sort__c";
					$scope.reversePostcode = false;
					$scope.walkpostcodeData = result;
					angular.forEach($scope.walkpostcodeData, function(e){
						if(!e.MCPM_Rep__c)
							e.MCPM_Rep__c = '';
						if(!e.MCPM_Future_Rep__c)
							e.MCPM_Future_Rep__c = '';
						if($filter('contains')($scope.selectedPostcodes, e.Name))
					        e.select = true;
					});
					$scope.totalItemsPostcode = $scope.walkpostcodeData.length;
					$scope.currentPagePostcode = 1;
					$scope.$watch('currentPagePostcode + itemsPerPage', $scope.paginatePostcode);
					$scope.loadedPostcode = true;
				} else {
					$scope.alertsPostcode = [{type: 'danger', msg: event.message}];
				}
			});   
		});
	};
	
	//open dialog with walk postcodes based on selected sectors
	$scope.assignPostcode = function(){
	    
	    $scope.searchTextPostcode = '';
	    $scope.selectedPostcodes = [];
	    $scope.$watch('searchTextPostcode', $scope.walkpostcode);
		$scope.loadedPostcode = false;
		$scope.alertsPostcode = null;
		$scope.walkpostcodeData = null;
		
		j$('#walkpostcodeModal').modal('show');
        
		$scope.selectedSectorIds = [];
		angular.forEach($scope.selectedSectors, function(e){
            $scope.selectedSectorIds.push(e.Id);
        });
        
        $scope.walkpostcode();
	};
	
	//paginate method for walk postcode
	$scope.paginatePostcode = function() {
		var beginPostcode = (($scope.currentPagePostcode - 1) * $scope.itemsPerPage),
		endPostcode = beginPostcode + $scope.itemsPerPage;
		$scope.filteredwalkpostcodeData = $scope.walkpostcodeData.slice(beginPostcode, endPostcode);
		$scope.selectAllPostcode = false;
	};
	
	//change sort options on walk postcode
	$scope.changeSortPostcode = function(value) {
		if ($scope.sortPostcode == value){
            $scope.reversePostcode = !$scope.reversePostcode;
            $scope.walkpostcodeData = $filter('orderBy')($scope.walkpostcodeData, $scope.sortPostcode, $scope.reversePostcode);
            $scope.currentPagePostcode = 1;
            $scope.paginatePostcode();
            return;
		}
		
		$scope.sortPostcode = value;
		
		$scope.reversePostcode = false;
		
		$scope.walkpostcodeData = $filter('orderBy')($scope.walkpostcodeData, $scope.sortPostcode, $scope.reversePostcode);
		$scope.currentPagePostcode = 1;
		$scope.paginatePostcode();
	};
	
	//selection method for walk postcodes
	$scope.selectPostcode = function(index) {
	    var begin = (($scope.currentPagePostcode - 1) * $scope.itemsPerPage);
	    index = index + begin;
	    var selectedPostcode = $scope.walkpostcodeData[index];
	    if(selectedPostcode.select)
	        $scope.selectedPostcodes.push(selectedPostcode);
	    else {
	        var i = $filter('findIndex')($scope.selectedPostcodes, selectedPostcode.Name);
	        $scope.selectedPostcodes.splice(i, 1);
	    }
	};
	
	//select all action at the table header
	$scope.selectActionPostcode = function() {
	    if($scope.selectAllPostcode){
	        $filter('addAll')($scope.filteredwalkpostcodeData, $scope.selectedPostcodes);
	    } else {
            $filter('removeAll')($scope.filteredwalkpostcodeData, $scope.selectedPostcodes);
	    }
	};
	
	//opening up update rep model (current and future)
	$scope.reassignPostcodeRep = function(current) {
	   
	    $scope.assigningCurrent = current;
	    $scope.collapseInput = false;
	    $scope.selectedRep = '';
	    $scope.isFromSector = false;
	    $scope.isFromPostcode = true;
	    $scope.dialogAlerts = [];
	    j$('#reassignRepModal').modal('show');
	};
	
	//save action from update rep model
	$scope.savePostcodeRepAssignment = function() {
	    
	    j$('#savePostcodeRepAssignment').button('loading');
	    $scope.dialogAlerts = [];
	    var postcodes = [];
	    var postcode;
	    
	    angular.forEach($scope.selectedPostcodes, function(e){
	        
            if($scope.assigningCurrent){
	            postcode = {Id : e.Id, MCPM_Rep__c : $scope.selectedRep};
    	    } else {
    	        postcode = {Id : e.Id, MCPM_Future_Rep__c : $scope.selectedRep};
    	    }
    	    postcodes.push(postcode);
        });
	    
	    savePostcodesR(postcodes, function(result, event){  
			$scope.$apply(function(){  
				if(event.status) {
				    $scope.selectedPostcodes = [];
				    $scope.collapseInput = true;
                    j$('#savePostcodeRepAssignment').button('reset');
                    $scope.dialogAlerts = [{type: 'success', msg: 'Success!!'}];
				} else {
					$scope.dialogAlerts = [{type: 'danger', msg: event.message}];
					j$('#savePostcodeRepAssignment').button('reset');
				}
			});   
		});
	};
	
	$scope.savePostcode = function(value){
		
		var row = $scope.filteredwalkpostcodeData[value];
		row.fade = true;
		var update = angular.copy($scope.filteredwalkpostcodeData[value]);
		
		delete update.MCPM_Rep__r;
		delete update.fade;
		delete update.Owner;
		delete update.select;
		 
		savePostcodeR(update, function(result, event){  
			$scope.$apply(function(){  
				if(event.status) {
					if(!result.MCPM_Rep__c)
						result.MCPM_Rep__c = '';
					if(!result.MCPM_Future_Rep__c)
						result.MCPM_Future_Rep__c = '';
					if($filter('contains')($scope.selectedPostcodes, result.Name))
					    result.select = true;
					$scope.filteredwalkpostcodeData[value] = result;
					$scope.walkpostcodeData[20 * ($scope.currentPage - 1) + value] = result;
					row.fade = false;
				} else {
				    row.fade = false;
					$scope.alerts = [{type: 'danger', msg: event.message}];
				}
			});   
		});
	};
	
	$scope.autoAssign = function(value){
		
		$scope.showFuture = true;
		$scope.showCurrent = false;
        $scope.show = "Future";
		
		$scope.currentPagePostcode = 1;
		$scope.loadedPostcode = false;
		$scope.alertsPostcode = null;
		$scope.walkpostcodeData = null;
		$scope.searchTextPostcode = '';
		
		tmpList = [];
		
		angular.forEach($scope.list, function(e){
			if(e.checked)
				tmpList.push({
					value: e.value,
					key: e.key,
				});
		});
		
		autoAssignR(tmpList, $scope.selectedSectorIds, function(result, event){  
			$scope.$apply(function(){  
				
				if(event.status) {
					$scope.sortPostcode = "MCPM_Postcode_Sort__c";
					$scope.reversePostcode = false;
					$scope.walkpostcodeData = result;
					angular.forEach($scope.walkpostcodeData, function(e){
						if(!e.MCPM_Rep__c)
							e.MCPM_Rep__c = '';
						if(!e.MCPM_Future_Rep__c)
							e.MCPM_Future_Rep__c = '';
					});
					$scope.totalItemsPostcode = $scope.walkpostcodeData.length;
					$scope.$watch('currentPagePostcode + itemsPerPage', $scope.paginatePostcode);
					$scope.loadedPostcode = true;
				} else {
					$scope.alertsPostcode = [{type: 'danger', msg: event.message}];
				}
			});   
		});
	};
	
	$scope.agentsInfo = function() {
	    
	    $scope.dialogLoaded = false;
		$scope.agents = null;
		var current;
		if($scope.showAssignments == 'current')
            current = true;
		else
            current = false;
		agentsInfoR(current, ($scope.forSectors ? $scope.selectedSectorIds : []), $scope.isRSM, function(result, event){  
			$scope.$apply(function(){  
				
				if(event.status) {
					$scope.agents = result;
					$scope.dialogLoaded = true;
				} else {
					$scope.alerts = [{type: 'danger', msg: event.message}];
				}
			});   
		});
	};
  
	$scope.sortableOptions = {
		handle: '> .cursor-move',
		update: function(e, ui) {
			tmpList.map(function(i){
				return i.value;
			}).join(', ');
		},
		stop: function(e, ui) {
			// this callback has the changed model
			tmpList.map(function(i){
				return i.value;
			}).join(', ');
		}
	};
	
	$scope.addNewPostcode = function(){
        
        j$('#addNewPostcodeModal').modal('show');
        $scope.collapseInput = false;
        $scope.dialogAlerts = [];
        $scope.newWalkPostcode = angular.copy(masterWalkPostcode);
        $scope.newWalkPostcode.Name = '';
        $scope.newWalkPostcode.OwnerId = '';
        $scope.newWalkPostcode.MCPM_Rep__c = '';
	};
	
	$scope.saveWalkPostcode = function(){
        
        j$('#saveWalkPostcode').button('loading');
		$scope.dialogAlerts = null;
        var insert = angular.copy($scope.newWalkPostcode);
		delete insert.attributes;
		
		saveWalkPostcodeR(insert, function(result, event){  
			$scope.$apply(function(){  
				if(event.status) {
                    if(result.length==18) {
                        $scope.collapseInput = true;
                        j$('#saveWalkPostcode').button('reset');
                        $scope.dialogAlerts = [{type: 'success', msg: 'You successfully created a walk postcode.'}];
                    } else {
                        $scope.dialogAlerts = [{type: 'danger', msg: result}];
                        j$('#saveWalkPostcode').button('reset');
                    }
				} else {
					$scope.dialogAlerts = [{type: 'danger', msg: event.message}];
					j$('#saveWalkPostcode').button('reset');
				}
			});
		});
	};
});