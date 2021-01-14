/**
 * Class was provided by fonteva to allow the calculation of taxes based on custom county field.
 */
global inherited sharing class TaxService extends FDService.TaxService {

    global TaxService () {}

    public override List<FDService.SalesOrderLine> configureTaxes(List<FDService.SalesOrderLine> records, Boolean refreshTaxes, Map<Id, FDService.SalesOrderLine> oldMap) {
        List<FDService.SalesOrderLine> lines = getSuper().configureTaxes(records,false,oldMap);
        if (refreshTaxes) {
            Set<Id> salesOrderLineIds = new Set<Id>();
            for (FDService.SalesOrderLine sol : records) {
                if (sol.id != null) {
                    salesOrderLineIds.add(sol.id);
                }
            }
            if (salesOrderLineIds.size() > 0) {
                delete [SELECT Id FROM OrderApi__Sales_Order_Line__c WHERE OrderApi__Is_Tax__c = true AND OrderApi__Sales_Order_Line__c IN :salesOrderLineIds];
            }
            return FDService.SalesOrderLineService.getInstance().mutate(lines);
        }
        return lines;
    }
}