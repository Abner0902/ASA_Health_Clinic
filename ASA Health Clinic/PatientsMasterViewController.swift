//
//  MasterViewController.swift
//  ASA Health Clinic
//
//  Created by zhenyu on 31/5/17.
//  Copyright © 2017 zhenyu. All rights reserved.
//

import UIKit
import CoreData

extension PatientsMasterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

class PatientsMasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, AddPatientDelegate, UpdatePatientDelegate {
    
    var filteredPatients = [Patient]()
    var patients = [Patient]()

    var detailViewController: PatientsDetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var patientToSelect: Patient? {
        get {
            return (self.tabBarController!.viewControllers![1] as! OverviewTableViewController).patientToView
        }
    }

    @IBOutlet var patientTableView: UITableView!

    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = ManagedContext().getManagedObject()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PatientsDetailViewController
        }
        
        patients = fetchedResultsController.fetchedObjects!
        
        patientTableView.tableFooterView = UIView()
        patientTableView.allowsSelectionDuringEditing = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.preSetTable()
        
        //appFirstLaunchSetup()
        
        
    }
    
    func preSetTable() {
        let indexPath = IndexPath(row: 0, section: 0)
        if patients.count != 0 && patientToSelect == nil {
            selectTableRow(indexPath: indexPath)
        } else if patients.count != 0, let patient = patientToSelect {
            
            let index = getPatientRowByName(name: patient.name!)
            
            let indexPath = IndexPath(row: index, section: 0)
            selectTableRow(indexPath: indexPath)
        }

    }
    
    func selectTableRow(indexPath: IndexPath) {
        self.patientTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        self.tableView(self.patientTableView, didSelectRowAt: indexPath)
    }
    
    func getPatientRowByName(name: String) -> Int{
        for patient in patients {
            if patient.name == name {
                return patients.index(of: patient)!
            }
        }
        
        return 0
    }
    
    //helper method for search bar
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPatients = patients.filter { patient in
            
            return (patient.name?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    func updatePatient(name: String, phone: String, patientToUpdate: Patient){
        PatientManager().updatePatient(name: name, phone: phone, patientToUpdate: patientToUpdate)
    }

    override func viewWillAppear(_ animated: Bool) {
        //clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        self.preSetTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "patientDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! PatientsDetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "addPatientSegue" {
            //prepare for adding patient
            let destinationVC: AddPatientViewController = segue.destination as! AddPatientViewController
            destinationVC.delegate = self
        } else if segue.identifier == "editPatientSegue"{
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = fetchedResultsController.object(at: indexPath)
                let destinationVC: UpdatePatientViewController = segue.destination as! UpdatePatientViewController
                destinationVC.delegate = self
                destinationVC.currentPatient = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredPatients.count
        } else {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath)
        let patient: Patient
        if searchController.isActive && searchController.searchBar.text != "" {
            patient = filteredPatients[indexPath.row]
        } else {
            patient = fetchedResultsController.object(at: indexPath)
        }
        configureCell(cell, withPatient: patient)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            let patientToDelete = fetchedResultsController.object(at: indexPath)
            
            PatientManager().deletePatient(patientToDelete: patientToDelete, context: context)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //check the table view is in edit mode or not
        if (tableView.isEditing == true) {
            //in edit then perform edit segue
            performSegue(withIdentifier: "editPatientSegue", sender: self)
        } else {
            //not in edit then perform view detal segue
            performSegue(withIdentifier: "patientDetailSegue", sender: self)
        }
        
    }

    func configureCell(_ cell: UITableViewCell, withPatient patient: Patient) {
        cell.textLabel!.text = patient.name!
    }

    // MARK: - Fetched results controller 

    var fetchedResultsController: NSFetchedResultsController<Patient> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController! 
        }
        
        let fetchRequest: NSFetchRequest<Patient> = Patient.fetchRequest()
        
        // Set the batch size to a suitable number.
        // should not limit the batch size
        // fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "PatientMaster")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            
            
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Patient>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withPatient: anObject as! Patient)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withPatient: anObject as! Patient)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // Mark: - Delegate methods
    //Add patient
    func addPatient(name: String, phone: String) {
        PatientManager().addPatient(name: name, phone: phone)
    }
    
//    func appFirstLaunchSetup() {
//        let defaults = UserDefaults.standard
//            
//        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
//            NSLog("App already launched : \(isAppAlreadyLaunchedOnce)")
//        }else{
//            //app launch first time
//            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
//            
//            setupClinicAndDoctorTable()
//        }
//    }
//    
//    func setupClinicAndDoctorTable() {
//        let context = ManagedContext().getManagedObject()
//        let clinic1 = NSEntityDescription.insertNewObject(forEntityName: "Clinic", into: context) as? Clinic
//        
//        clinic1?.address = "Room 1402, Chuang’s Tower, 30-32 Connaught Road, Central, Hong Kong"
//        clinic1?.phone = "85228269261"
//        
////        let clinic2 = NSEntityDescription.insertNewObject(forEntityName: "Clinic", into: context) as? Clinic
////        
////        clinic2?.address = "Clinic2"
////        clinic2?.phone = "0431739405"
////        
////        let clinic3 = NSEntityDescription.insertNewObject(forEntityName: "Clinic", into: context) as? Clinic
////        
////        clinic3?.address = "Clinic3"
////        clinic3?.phone = "0431739405"
//        
//        let doctor1 = NSEntityDescription.insertNewObject(forEntityName: "Doctor", into: context) as? Doctor
//        
//        doctor1?.name = "Andy Kwok"
//        
//        let doctor2 = NSEntityDescription.insertNewObject(forEntityName: "Doctor", into: context) as? Doctor
//        
//        doctor2?.name = "Stephen Wong"
//        
////        let doctor3 = NSEntityDescription.insertNewObject(forEntityName: "Doctor", into: context) as? Doctor
////        
////        doctor3?.name = "Doctor3"
//        
//        clinic1?.addDoctor(doctor1!)
//        clinic1?.addDoctor(doctor2!)
////        clinic3?.addDoctor(doctor3!)
//        
//        //Save the ManagedObjectContext
//        do {
//            try context.save()
//            
//        } catch let error as NSError {
//            print("Could not save \(error), \(error.userInfo)")
//        }
//
//    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

