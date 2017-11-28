using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetInventoryDonut(string classId)
    {
        string resp = "";
        try
        {
            string invQ = "SELECT InventoryStatus,InventoryCount FROM InventoryDonutView WHERE Classroom_rid = " + classId;
            List<Dictionary<string, string>> retLst = new List<Dictionary<string, string>>();
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(invQ, "Library");
            for (int i = 0; i < ret.Count; i++)
            {
                Dictionary<string, string> retObj = ret[i];
                Dictionary<string, string> lstObj = new Dictionary<string, string>();
                lstObj.Add("label", retObj["InventoryStatus"]);
                lstObj.Add("value", retObj["InventoryCount"]);
                retLst.Add(lstObj);
            }
            resp = JsonConvert.SerializeObject(retLst);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetLoanLength(string classId)
    {
        string resp = "";
        try
        {
            string loanQ = "SELECT AvgLoanLength FROM ClassroomLoanTimeView WHERE Classroom_rid = " + classId;
            string ret = "";
            ret = DBUtility.ExecuteScalar(loanQ, "Library");

            if (ret == "")
            {
                resp = "NA";
            }
            else
            {
                resp = ret;
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetPopularBooks(string classId)
    {
        string resp = "";
        try
        {
            string popQ = "SELECT TOP 5 * FROM ClassroomBookLoanCountView WHERE Classroom_rid = " + classId + " ORDER BY LoanCount DESC";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(popQ, "Library");

            if (ret.Count > 0)
            {
                resp = JsonConvert.SerializeObject(ret);
            }
            else
            {
                resp = "X";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetMonthLoans(string classId)
    {
        string resp = "";
        try
        {
            string[] months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
            List<Dictionary<string, string>> retDict = new List<Dictionary<string, string>>();
            for (int i = 0; i < months.Length; i++)
            {
                string monthName = months[i];
                Dictionary<string, string> monthDict = new Dictionary<string, string>();
                string monthQ = "SELECT * FROM ClassroomMonthLoanCountView WHERE Classroom_rid = " + classId + " AND LoanMonth = '" + monthName + "'";
                Dictionary<int, Dictionary<string, string>> monthRet = DBUtility.SqlRead(monthQ, "Library");
                if (monthRet.Count > 0)
                {
                    Dictionary<string, string> monthRetObj = monthRet[0];
                    monthDict.Add("LoanMonth", monthName);
                    monthDict.Add("LoanCount", monthRetObj["LoanCount"]);
                }
                else
                {
                    monthDict.Add("LoanMonth", monthName);
                    monthDict.Add("LoanCount", "0");
                }
                retDict.Add(monthDict);
            }
            resp = JsonConvert.SerializeObject(retDict);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}