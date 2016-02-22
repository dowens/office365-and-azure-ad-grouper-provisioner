Grouper action: 1.0 Place a marker on a folder
Target outcome: add all the groups under that folder and any subfolder, and all the group memberships
Test 1.0.1: Marking a parent folder
1) setup folder structure with groups, sub folders, and groups in sub folders
2) place syncAttribute marker on parent folder
Outcome:
1) all groups within folder structure added to the target
GSH:
// Test 1.0.1 Marking a parent folder
gs = GrouperSession.startRootSession();
bob = "banderson";
ann = "agasper";
bill = "bbrown705";
testFolderName = "test_1_0_1"

// add group1 and membership to parent folder
parentFolderName = testFolderName + ":parentFolder";
group1Name = parentFolderName + ":group1";
group1 = new GroupSave(gs).assignName(group1Name).assignGroupNameToEdit(group1Name).assignSaveMode(SaveMode.INSERT_OR_UPDATE).assignCreateParentStemsIfNotExist(true).save();
addMember(group1Name, bob);
addMember(group1Name, ann);
addMember(group1Name, bill);

// add group2 and membership to subfolder
subFolderName = parentFolderName + ":subFolder"
group2Name = subFolderName + ":group2";
group2 = new GroupSave(gs).assignName(group2Name).assignGroupNameToEdit(group2Name).assignSaveMode(SaveMode.INSERT_OR_UPDATE).assignCreateParentStemsIfNotExist(true).save();
addMember(group2Name, bob);
addMember(group2Name, ann);
addMember(group2Name, bill);

// wait for grouper_debug.log:
//      changeLog.consumer.print skipping addMembership for subject Bill Brown since group test_1_0_1:parentFolder:subFolder:group2 is not marked for sync
//

// add syncAttribute mark to parent folder
syncAttr = AttributeDefNameFinder.findByName("etc:attribute:changeLogConsumer:printSync", true);
parentFolder = StemFinder.findByName(gs, parentFolderName, true);
parentFolder.getAttributeDelegate().addAttribute(syncAttr);

// wait for grouper_debug.log:
//      changeLog.consumer.print add group test_1_0_1:parentFolder:group1 and memberships
//      changeLog.consumer.print add group test_1_0_1:parentFolder:subFolder:group2 and memberships
// end of Test 1.0.1 Marking a parent folder

// Test 1.0.1 teardown
delGroup(group2Name);
delStem(subFolderName);
delGroup(group1Name);
delStem(parentFolderName);
delStem(testFolderName);
// end of Test 1.0.1 teardown


Grouper action: 1.1 Remove a marker from a folder
Target outcome: remove groups under that folder and any subfolder (and implicitly all the memberships), unless otherwise marked from a parent folder or has a direct assignment
Test 1.1.1: Removing mark from parent folder with subfolders and groups (and no other marks)
1) Test 1.0.1
2) Remove syncAttribute marker from parent folder
Outcome:
1) all groups within folder structure removed from target
GSH:
// Test 1.1.1 Removing mark from parent folder with subfolders and groups (and no other marks)
gs = GrouperSession.startRootSession();
bob = "banderson";
ann = "agasper";
bill = "bbrown705";
testFolderName = "test_1_0_1"

// add group1 and membership to parent folder
parentFolderName = testFolderName + ":parentFolder";
group1Name = parentFolderName + ":group1";
group1 = new GroupSave(gs).assignName(group1Name).assignGroupNameToEdit(group1Name).assignSaveMode(SaveMode.INSERT_OR_UPDATE).assignCreateParentStemsIfNotExist(true).save();
addMember(group1Name, bob);
addMember(group1Name, ann);
addMember(group1Name, bill);

// add group2 and membership to subfolder
subFolderName = parentFolderName + ":subFolder"
group2Name = subFolderName + ":group2";
group2 = new GroupSave(gs).assignName(group2Name).assignGroupNameToEdit(group2Name).assignSaveMode(SaveMode.INSERT_OR_UPDATE).assignCreateParentStemsIfNotExist(true).save();
addMember(group2Name, bob);
addMember(group2Name, ann);
addMember(group2Name, bill);

// add syncAttribute mark to parent folder
syncAttr = AttributeDefNameFinder.findByName("etc:attribute:changeLogConsumer:printSync", true);
parentFolder = StemFinder.findByName(gs, parentFolderName, true);
parentFolder.getAttributeDelegate().addAttribute(syncAttr);

// wait for grouper_debug.log:
//      changeLog.consumer.print add group test_1_0_1:parentFolder:group1 and memberships
//      changeLog.consumer.print add group test_1_0_1:parentFolder:subFolder:group2 and memberships

// remove syncAttribute mark
parentFolder.getAttributeDelegate().removeAttribute(syncAttr);

// wait for group_debug.log:



// end of Test 1.0.1 Marking a parent folder

// Test 1.0.1 teardown
delGroup(group2Name);
delStem(subFolderName);
delGroup(group1Name);
delStem(parentFolderName);
delStem(testFolderName);
// end of Test 1.0.1 teardown







Test 1.1.2: Marked folder with marked subfolders
1) Test 1.0.1
2) Mark subfolder with syncAttribute
3) Remove syncAttribute from parent folder
Outcome:
1) all groups within parent folder structure removed from target, expect those within marked subfolder


Test 1.1.3: Marked folder with marked groups
1) Test 1.0.1
2) Mark group in parent folder and sub folder structure
3) Remove syncAttribute from parent folder
Outcome:
1) all groups within parent folder structure removed from target, except the two directly marked groups


Grouper action: 1.2 Place a marker on a group
Target outcome: add the group and all its effective memberships (direct and indirect)
Test 1.2.1:
1) Set up folder and a group with memberships, and no syncAttribute marks
2) Mark group with syncAttribute
Outcome:
1) group and its memberships add to the target

Grouper action: 1.3 Remove a marker from a group
Target outcome: remove the group (and implicitly all the memberships), unless otherwise marked by a parent folder
Test 1.3.1:
1) Test 1.2.1
2) Remove marker from the group
Outcome:
1) group removed from target

Test 1.3.2:
1) Test 1.2.1
2) Mark parent folder (adding an implicit syncAttribute mark)
3) Remove the direct marker from the group
Outcome:
1) Group is *not* removed from target, since it has an indirect mark from parent folder


Grouper action: 2.0 Add indirectly marked group (i.e. add a group under a folder that is already marked)
Target outcome: add the group
Test 2.0.1:
1) Set up folder with syncAttribute mark
2) Add (or move?) group to folder (or subfolder)
Outcome:
1) Group and its membership (in case of moved with membership) added to target


Grouper action: 3.0 Delete a directly marked group*
Target outcome: remove the group
Test 3.0.1:
1) Test 1.2.1
2) Delete group
Outcome:
1) group removed from target


Grouper action: 3.1 Delete an indirectly marked group*
Target outcome: remove the group
Test 3.1.0
1) Test 2.0.1
2) Delete group
Outcome:
1) group removed from target


Grouper action: 4.0 Membership add on a marked group (directly or indirectly marked)
Target outcome: add membership
Test 4.0.1: Membership add to directly marked group
1) Test 1.2.1
2) Add member to group
Outcome:
1) members added to group at target

Test 4.0.2: Membership add to indirectly marked group (i.e. parent folder is marked)
1) Test 2.0.1
2) Add member to group
Outcome:
1) members added to group at target

Test 4.0.3: Membership add by grouper effective membership (via sub groups or group math)
1) Test 4.0.1
2) Add a sub group with membership to marked group
Outcome:
1) New effective members via subgroup are added to group at target


Grouper action: 4.1 Membership delete on a marked group (directly or indirect marked)
Target outcome: remove membership
Test 4.1.1: Membership delete to directly marked group
1) Test 4.0.1
2) Remove member from marked group
Outcome:
1) membership removed from target

Test 4.1.2 Membership delete to indirectly marked group (i.e. parent folder is marked)
1) Test 4.0.2
2) Remove member from indirectly marked group
Outcome:
1) membership removed from target

Test 4.1.3 Membership delete by grouper effective membership (via sub groups or group math)
1) Test 4.0.3
2) Remove subgroup from marked group
Outcome:
1) Indirect memberships due to subgroup removed from target













