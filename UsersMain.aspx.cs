using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class UsersMain : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetYearStudents(string rid, string classId)
    {
        string resp = "";
        
        try
        {           
            string yearQ = "SELECT * FROM SelectViewStudent WHERE SchoolYear_rid = " + rid + " AND Classroom_rid = " + classId + " ORDER BY StudentName";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(yearQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }

        return resp;
    }

    [WebMethod]
    public static string AddNewStudent(string classId, string stuYear, string stuName)
    {
        string resp = "";
        try
        {
            string instStuQ = "INSERT INTO Student (StudentName,Classroom_rid,SchoolYear_rid) VALUES ('" + stuName + "'," + classId + "," + stuYear + ")";
            DBUtility.ExecuteSql(instStuQ, "Library");
            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string ShowEditStudentModal(string classId, string stuId)
    {
        string resp = "";
        try
        {
            string stuQ = "SELECT * FROM Student WHERE rid = " + stuId;
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(stuQ, "Library");
            Dictionary<string, string> retObj = ret[0];
            resp = JsonConvert.SerializeObject(retObj);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string EditStudent(string stuId, string stuName, string stuActive)
    {
        string resp = "";
        try
        {
            string stuUpdtQ = "UPDATE Student SET StudentName = '" + stuName + "', Active = " + stuActive + " WHERE rid = " + stuId;
            DBUtility.ExecuteSql(stuUpdtQ, "Library");
            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}