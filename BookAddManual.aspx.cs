using System;
using System.Collections.Generic;
using System.Web.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class BookAdd : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    [WebMethod]
    public static string GetAuthors()
    {
        string resp = "";
        try
        {
            string authorQ = "SELECT * FROM Author ORDER BY FirstName";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(authorQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string GetPublishers()
    {
        string resp = "";
        try
        {
            string pubQ = "SELECT * FROM Publisher ORDER BY PublisherName";
            Dictionary<int, Dictionary<string, string>> ret = DBUtility.SqlRead(pubQ, "Library");
            resp = JsonConvert.SerializeObject(ret);
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }

    [WebMethod]
    public static string AddNewBook(string title, string isbn10, string isbn13, string inv,
        string authSel, string authEnter, string pubSel, string pubEnter, string classId)
    {
        string resp = "";
        try
        {
            title.Replace("`", "''");
            isbn10.Replace("`", "''");
            isbn13.Replace("`", "''");
            inv.Replace("`", "''");
            authEnter.Replace("`", "''");
            pubEnter.Replace("`", "''");
            
            // see if his book is already in db based on isbn
            string checkQ = "SELECT * FROM Book WHERE (ISBN_10 = '" + isbn10 + "' AND ISBN_10 > '') OR (ISBN_13 = '" + isbn13 + "' AND ISBN_13 > '')";
            Dictionary<int, Dictionary<string, string>> checkRet = DBUtility.SqlRead(checkQ, "Library");
            int checkRes = checkRet.Count;
            if (checkRes > 0)
            {
                resp = "We already have this book!";
            }
            else
            {
                // first check if publisher needs to be created
                string pubId;
                if (pubSel == "")
                {
                    // no publisher selected, so we need to create one
                    string instPubQ = "INSERT INTO Publisher (PublisherName) OUTPUT INSERTED.rid VALUES ('" + pubEnter + "')";
                    pubId = DBUtility.ExecuteScalar(instPubQ, "Library");
                }
                else
                {
                    pubId = pubSel;
                }

                // check if author needs to be created
                string authId;
                if (authSel == "")
                {
                    string authFName = "";
                    string authLName = "";
                    string[] authNames;
                    authNames = authEnter.Split(' ');
                    int authNameCt = authNames.Length;
                    authLName = authNames[authNameCt - 1];
                    for (int i = 0; i < authNameCt - 1; i++)
                    {
                        authFName += authNames[i];
                    }

                    string instAuthQ = "INSERT INTO Author (FirstName,LastName) OUTPUT INSERTED.rid VALUES ('" + authFName + "','" + authLName + "')";
                    authId = DBUtility.ExecuteScalar(instAuthQ, "Library");
                }
                else
                {
                    authId = authSel;
                }

                // now create the book
                string bookId = "";
                string instBookQ = "INSERT INTO Book (BookTitle,ISBN_10,ISBN_13,Publisher_rid) VALUES ('" + title + "','" + isbn10 + "','" + isbn13 + "'," + pubId + ")";
                DBUtility.ExecuteSql(instBookQ, "Library");
                string getNewBook = "SELECT rid FROM Book WHERE BookTitle = '" + title + "' AND ISBN_10 = '" + isbn10 +"' AND ISBN_13 = '" + isbn13 + "' AND Publisher_rid = " + pubId;
                bookId = DBUtility.ExecuteScalar(getNewBook, "Library");

                // create the relationship to the author
                string bookAuthQ = "INSERT INTO Book_Author (Book_rid, Author_rid) VALUES (" + bookId + "," + authId + ")";
                DBUtility.ExecuteSql(bookAuthQ, "Library");

                // add the class inventory
                int invCt = Int32.Parse(inv);
                for (int j = 0; j < invCt; j++)
                {
                    string invQ = "INSERT INTO Inventory (Book_rid,InventoryStatus,Classroom_rid) VALUES (" + bookId + ",'IN'," + classId + ")";
                    DBUtility.ExecuteSql(invQ, "Library");
                }

                resp = "OK";
            }
        }
        catch (Exception e)
        {
            resp = "X";
        }
        return resp;
    }
}