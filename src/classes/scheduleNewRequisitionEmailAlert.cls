global class scheduleNewRequisitionEmailAlert implements Schedulable {
   global void execute(SchedulableContext sc) {
      //Instantiate batch class & execute
      batchNewRequisitionEmailAlert b = new batchNewRequisitionEmailAlert(); 
      database.executebatch(b);
   }
}