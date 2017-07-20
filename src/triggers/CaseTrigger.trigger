trigger CaseTrigger on Case (after insert) {
CASETriggerhandler.copyFilesSubCase(trigger.new);
}