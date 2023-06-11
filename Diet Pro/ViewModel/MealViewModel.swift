//
//  MealViewModel.swift
//  Diet Pro
//
//  Created by Lyan Alwakeel on 26/09/2022.
//

import Foundation


func instanceFromJSON(typeName: String, json: String) -> AnyObject?
    { let jdata = json.data(using: .utf8)!
      let decoder = JSONDecoder()
      if typeName == "String"
      { let x = try? decoder.decode(String.self, from: jdata)
          return x as AnyObject
      }
  return nil
    }


class MealViewModel: ObservableObject {
    static var instance : MealViewModel? = nil
    @Published var currentMeal : MealVO? = MealVO.defaultMealVO()
    @Published var currentMeals : [MealVO] = [MealVO]()
    
    static func getInstance() -> MealViewModel {
        if instance == nil
         { instance = MealViewModel()}
        return instance! }
    
    @Published var name = ""
    @Published var type = ""
    @Published var calories = 0.0
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    // Calculates the total calories consumed today
    var consumedClaories: Double {
        var caloriesToday : Double = 0
        for meal in currentMeals {
            caloriesToday += meal.calories
        }
        return caloriesToday
    }
            

    let dbpath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    var fileSystem : FileAccessor = FileAccessor()
    var db : DB?
    
    init() {
        db = DB.obtainDatabase(path: "\(dbpath)/myDatabase.sqlite3")
    }
    //CRUD
    func createMeal(x : MealVO) {
          let res : Meal = createByPKMeal(key: x.mealId)
                res.mealId = x.mealId
        res.mealName = x.mealName
        res.calories = x.calories
        res.dates = x.dates
        res.images = x.images
        res.analysis = x.analysis
        res.userName = x.userName
          currentMeal = x
          do { try db?.createMeal(mealvo: x) }
          catch { print("Error creating Meal") }
    }
        
    func cancelCreateMeal() {
        //cancel function
    }
    
    func deleteMeal(id : String) {
          if db != nil
          { db!.deleteMeal(val: id) }
             currentMeal = nil
    }
        
    func cancelDeleteMeal() {
        //cancel function
    }
            
    func cancelEditMeal() {
        //cancel function
    }

    func cancelSearchMealByDate() {
    //cancel function
        
    }
    
    func loadMeal() {
        let res : [MealVO] = listMeal()
        
        for (_,x) in res.enumerated() {
            let obj = createByPKMeal(key: x.mealId)
            obj.mealId = x.getMealId()
        obj.mealName = x.getMealName()
        obj.calories = x.getCalories()
        obj.dates = x.getDates()
        obj.images = x.getImages()
        obj.analysis = x.getAnalysis()
        obj.userName = x.getUserName()
            }
         currentMeal = res.first
         currentMeals = res
        }
        
          func listMeal() -> [MealVO] {
            if db != nil
            { currentMeals = (db?.listMeal())!
              return currentMeals
            }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { currentMeals.append(MealVO(x: x)) }
            return currentMeals
        }
                
        func stringListMeal() -> [String] {
            currentMeals = listMeal()
            var res : [String] = [String]()
            for (_,obj) in currentMeals.enumerated()
            { res.append(obj.toString()) }
            return res
        }
                
        func getMealByPK(val: String) -> Meal? {
            var res : Meal? = Meal.getByPKMeal(index: val)
            if res == nil && db != nil
            { let list = db!.searchByMealmealId(val: val)
            if list.count > 0
            { res = createByPKMeal(key: val)
            }
          }
          return res
        }
                
        func retrieveMeal(val: String) -> Meal? {
            let res : Meal? = getMealByPK(val: val)
            return res
        }
                
        func allMealids() -> [String] {
            var res : [String] = [String]()
            for (_,item) in currentMeals.enumerated()
            { res.append(item.mealId + "") }
            return res
        }
                
        func setSelectedMeal(x : MealVO)
            { currentMeal = x }
                
        func setSelectedMeal(i : Int) {
            if 0 <= i && i < currentMeals.count
            { currentMeal = currentMeals[i] }
        }
                
        func getSelectedMeal() -> MealVO?
            { return currentMeal }
                
        func persistMeal(x : Meal) {
            let vo : MealVO = MealVO(x: x)
            editMeal(x: vo)
        }
            
        func editMeal(x : MealVO) {
            let val : String = x.mealId
            let res : Meal? = Meal.getByPKMeal(index: val)
            if res != nil {
            res!.mealId = x.mealId
        res!.mealName = x.mealName
        res!.calories = x.calories
        res!.dates = x.dates
        res!.images = x.images
        res!.analysis = x.analysis
        res!.userName = x.userName
        }
        currentMeal = x
            if db != nil
             { db!.editMeal(mealvo: x) }
         }
            
        func cancelMealEdit() {
            //cancel function
        }
        
     func searchByMealmealId(val : String) -> [MealVO]
          {
              if db != nil
                { let res = (db?.searchByMealmealId(val: val))!
                  return res
                }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { if x.mealId == val
              { currentMeals.append(MealVO(x: x)) }
            }
            return currentMeals
          }
          
     func searchByMealmealName(val : String) -> [MealVO]
          {
              if db != nil
                { let res = (db?.searchByMealmealName(val: val))!
                  return res
                }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { if x.mealName == val
              { currentMeals.append(MealVO(x: x)) }
            }
            return currentMeals
          }
          
     func searchByMealcalories(val : Double) -> [MealVO]
          {
              if db != nil
                { let res = (db?.searchByMealcalories(val: val))!
                  return res
                }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { if x.calories == val
              { currentMeals.append(MealVO(x: x)) }
            }
            return currentMeals
          }
          
     func searchByMealdates(val : String) -> [MealVO]
          {
              if db != nil
                { let res = (db?.searchByMealdates(val: val))!
                  return res
                }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { if x.dates == val
              { currentMeals.append(MealVO(x: x)) }
            }
            return currentMeals
          }
          
     func searchByMealimages(val : String) -> [MealVO]
          {
              if db != nil
                { let res = (db?.searchByMealimages(val: val))!
                  return res
                }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { if x.images == val
              { currentMeals.append(MealVO(x: x)) }
            }
            return currentMeals
          }
          
     func searchByMealanalysis(val : String) -> [MealVO]
          {
              if db != nil
                { let res = (db?.searchByMealanalysis(val: val))!
                  return res
                }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { if x.analysis == val
              { currentMeals.append(MealVO(x: x)) }
            }
            return currentMeals
          }
          
     func searchByMealuserName(val : String) -> [MealVO]
          {
              if db != nil
                { let res = (db?.searchByMealuserName(val: val))!
                  return res
                }
            currentMeals = [MealVO]()
            let list : [Meal] = mealAllInstances
            for (_,x) in list.enumerated()
            { if x.userName == val
              { currentMeals.append(MealVO(x: x)) }
            }
            return currentMeals
          }
    
    func addUsereatsMeal(x: String, y: String) {
            if db != nil
            { db!.addUsereatsMeal(userName : x, mealId : y) }
              let userobj : User? = User.getByPKUser(index : x)
              let mealobj : Meal? = Meal.getByPKMeal(index : y)
            if userobj != nil
            {
                currentMeal = MealVO(x : mealobj!)
            }
      }
        
      func cancelAddUsereatsMeal() {
          //cancel function
      }

    func removeUsereatsMeal(x: String, y: String) {
            if db != nil
            { db!.removeUsereatsMeal(mealId : y) }
              let userobj : User? = User.getByPKUser(index : x)
              let mealobj : Meal? = Meal.getByPKMeal(index : y)
            if userobj != nil
            { 
                currentMeal = MealVO(x : mealobj!)
            }
      }
        
      func cancelRemoveUsereatsMeal() {
          //cancel function
      }
        
}
