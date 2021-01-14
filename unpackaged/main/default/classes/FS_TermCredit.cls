public class FS_TermCredit {
    public Map<String, Decimal> termCredits { get; set; }
    public Boolean originalPriceOverride { get; set; }
    public Double originalSalesPrice { get; set; }


    public static FS_TermCredit parse(String json) {
        return (FS_TermCredit) System.JSON.deserialize(json, FS_TermCredit.class);
    }
}