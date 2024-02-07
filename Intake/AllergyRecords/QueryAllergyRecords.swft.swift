//
//  QueryAllergyRecords.swft.swift
//  Intake
//
//  Created by Akash Gupta on 1/26/24.
//

import Foundation
import HealthKit

// class HealthKitManager {
//    let healthStore = HKHealthStore()
//
//    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
//        // Ensure that the allergy record type is available
//        guard let allergyRecordType = HKObjectType.clinicalType(forIdentifier: .allergyRecord) else {
//            fatalError("Allergy Record Type is no longer available in HealthKit")
//        }
//        
//        // Request authorization to access the data
//        healthStore.requestAuthorization(toShare: nil, read: Set([allergyRecordType])) { (success, error) in
//            completion(success, error)
//        }
//    }
//
//    func queryAllergyRecords() {
//        // Ensure that the allergy record type is available
//        guard let allergyRecordType = HKObjectType.clinicalType(forIdentifier: .allergyRecord) else {
//            fatalError("Allergy Record Type is no longer available in HealthKit")
//        }
//        
//        // Use a predicate to filter the results if necessary
//        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: nil, options: .strictEndDate)
//        
//        // Create the query
//        let query = HKSampleQuery(sampleType: allergyRecordType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
//            
//            guard let allergyRecords = results as? [HKClinicalRecord] else {
//                print("An error occurred fetching the user's allergy records: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            // Process the results
//            for allergyRecord in allergyRecords {
//                // You can access various properties of the allergy record here
//                // For example: allergyRecord.displayName, allergyRecord.FHIRResource?.data, etc.
//            }
//        }
//        
//        // Execute the query
//        healthStore.execute(query)
//    }
// }
//
//// Usage
// let healthKitManager = HealthKitManager()
// healthKitManager.requestAuthorization { (authorized, error) in
//    guard authorized else {
//        print("Permission denied: \(error?.localizedDescription ?? "Unknown error")")
//        return
//    }
//
//    // If we're authorized, query the allergy records
//    healthKitManager.queryAllergyRecords()
// }
