import Foundation

protocol MenuDelegate: AnyObject {
    func menu(_ sortingType: SortingType)
}

protocol DateDelegate: AnyObject {
    func datePicker(cell: DateTableCell, newDate: Date)
} 
