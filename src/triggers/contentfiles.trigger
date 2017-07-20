trigger contentfiles on ContentDocumentLink (after delete) {
contentdocumenthandler.HasAttachment(trigger.old);
}