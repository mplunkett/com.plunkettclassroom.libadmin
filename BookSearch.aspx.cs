using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class BookSearch : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string LoadBookList(string classId)
    {
        string resp = "";
        try
        {
            string bookQ = "SELECT * FROM InventoryClassBookView WHERE Classroom_rid = " + classId + " ORDER BY BookTitle";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(bookQ, "Library");
            if (ret.Count > 0)
            {
                resp = JsonConvert.SerializeObject(ret);
            }            
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetBooks(string classId, string bookName, string bookSel)
    {
        string resp = "";
        try
        {
            string whereQ = "";
            if (bookSel != "")
            {
                if (bookSel != "A")
                {
                    whereQ = " AND Book_rid = " + bookSel;
                }                
            }
            else
            {
                whereQ = " AND BookTitle LIKE '%" + bookName + "%'";
            }
            string bookQ = "SELECT * FROM InventoryClassBookView WHERE Classroom_rid = " + classId + whereQ + " ORDER BY BookTitle";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(bookQ, "Library");
            if (ret.Count > 0)
            {
                resp = JsonConvert.SerializeObject(ret);
            }
            else
            {
                resp = "0";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string LoadModalBook(string bookId)
    {
        string resp = "";
        try
        {
            string bookQ = "SELECT * FROM Book WHERE rid = " + bookId;
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(bookQ, "Library");
            if (ret.Count > 0)
            {
                Dictionary<string, string> retObj = ret[0];
                resp = JsonConvert.SerializeObject(retObj);
            }
            else
            {
                resp = "0";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string LoadCurrentAuthor(string bookId)
    {
        string resp = "";
        try
        {
            string authQ = "SELECT ISNULL(FirstName,'') + ' ' + ISNULL(MiddleName,'') + ' ' + ISNULL(LastName,'') As Name, rid FROM BookAuthorView WHERE Book_rid = " + bookId + " ORDER BY LastName";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(authQ, "Library");
            if (ret.Count > 0)
            {                
                resp = JsonConvert.SerializeObject(ret);
            }
            else
            {
                resp = "0";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string LoadAuthorList()
    {
        string resp = "";
        try
        {
            string authQ = "SELECT ISNULL(FirstName,'') + ' ' + ISNULL(MiddleName,'') + ' ' + ISNULL(LastName,'') As Name, rid FROM Author ORDER BY LastName";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(authQ, "Library");
            if (ret.Count > 0)
            {
                resp = JsonConvert.SerializeObject(ret);
            }
            else
            {
                resp = "0";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string SaveBookUpdate(string bookId, string bookName, string bookYear, string bookDesc)
    {
        string resp = "";
        try
        {
            string cleanBookName = bookName.Replace("`", "''");
            string cleanBookYear = bookYear.Replace("`", "''");
            string cleanBookDesc = bookDesc.Replace("`", "''");

            string updtQ = "UPDATE Book SET BookTitle = '" + cleanBookName + "', YearPublished = '" + cleanBookYear + "', BookDescription = '" + cleanBookDesc + "' WHERE rid = " + bookId;
            DBUtility.ExecuteSql(updtQ, "Library");
            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string RemoveBookAuthor(string bookAuthId)
    {
        string resp = "";
        try
        {
            string updtQ = "DELETE FROM Book_Author WHERE rid = " + bookAuthId;
            DBUtility.ExecuteSql(updtQ, "Library");
            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string AddBookAuthor(string bookId, string authId)
    {
        string resp = "";
        try
        {
            string updtQ = "INSERT INTO Book_Author (Book_rid, Author_rid) VALUES (" + bookId + "," + authId + ")";
            DBUtility.ExecuteSql(updtQ, "Library");
            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string LoadInventory(string bookId, string classId)
    {
        string resp = "";
        try
        {
            string invQ = "SELECT * FROM Inventory WHERE InventoryStatus IN ('IN','OUT') AND Classroom_rid = " + classId + " AND Book_rid = " + bookId;
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(invQ, "Library");
            if (ret.Count > 0)
            {
                resp = JsonConvert.SerializeObject(ret);
            }
            else
            {
                resp = "0";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string RetireInventory(string invId)
    {
        string resp = "";
        try
        {
            string updtQ = "UPDATE Inventory SET InventoryStatus = 'RETIRED' WHERE rid = " + invId;
            DBUtility.ExecuteSql(updtQ, "Library");
            resp = "OK";
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}