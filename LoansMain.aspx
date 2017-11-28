<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="LoansMain.aspx.cs" Inherits="LoansMain" %>
<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            LoadInventory();
        });

        function LoadInventory() {
            var classId = $("#LoggedClassVal").val();
            $.ajax({
                type: "POST",
                url: "LoansMain.aspx/GetInventory",
                data: "{classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "X") {
                        $("#BookSelect").html("");
                        $("#BookSelect").append("<option value=''>Select...</option>");
                        var retObj = jQuery.parseJSON(resp);
                        $.each(retObj, function (key, value) {
                            var element = "";
                            element += "<option value='" + value.Book_rid + "'>" + value.BookTitle + "</option>";
                            $("#BookSelect").append(element);
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function GetLoans() {
            var classId = $("#LoggedClassVal").val();
            var bookId = $("#BookSelect").val();
            var yearId = $("#YearSelect").val();
            var status = $("#StatusSelect").val();

            var dataString = "{classId: '" + classId + "',bookId: '" + bookId + "',yearId: '" + yearId + "',status: '" + status + "'}";
            $.ajax({
                type: "POST",
                url: "LoansMain.aspx/GetLoans",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {                    
                    var resp = msg.d;
                    $("#rsltTbl tbody").html("");
                    if (resp != "X") {
                        var retObj = jQuery.parseJSON(resp);
                        var elements = "";
                        $.each(retObj, function (key, value) {
                            var element = "";
                            element += "<tr>";
                            element += "<td>" + value.Inventory_rid + "</td>";
                            element += "<td>" + value.BookTitle + "</td>";
                            element += "<td>" + value.StudentName + "</td>";
                            element += "<td>" + value.LoanStatus + "</td>";
                            element += "<td>" + value.CheckOutDate + "</td>";
                            element += "</tr>";
                            elements += element;
                        });
                        $("#rsltTbl tbody").html(elements);
                    }
                    else {
                        alert("There was an error in operation");
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pagetitle" Runat="Server">
    <h2 class="pull-left"><i class="fa fa-bar-chart-o"></i> Loans</h2>
    <div class="clearfix"></div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="row">
        <div class="col-lg-12">
            <div class="widget wgreen">
                <div class="widget-head">                    
				    <div class="pull-left">Search Criteria</div>
		            <div class="widget-icons pull-right">
		                <i class="fa fa-search"></i>
		            </div>
		            <div class="clearfix"></div>
                </div>
                <div class="widget-content">
                    <div class="padd">
                        <div class="row">
                            <div class="col-lg-6 col-md-6">
                                <!-- Form Here -->
                                <form role="form">
                                    <div class="form-group">
                                        <label>Book</label>
                                        <select class="form-control" id="BookSelect">
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label>School Year</label>
                                        <select class="form-control" id="YearSelect">
                                            <option value="">Select...</option>
                                            <%
                                                string sYearQ = "SELECT * FROM SchoolYear ORDER BY StartDate DESC";
                                                Dictionary<int, Dictionary<string, string>> years = DBUtility.SqlRead(sYearQ, "Library");
                                                for (int i = 0; i < years.Count; i++)
                                                {
                                                    Dictionary<string, string> year = years[i];
                                                    string yearName = year["SchoolYearName"];
                                                    string yearRid = year["rid"];
                                                    Response.Write("<option value='" + yearRid + "'>" + yearName + "</option>");
                                                }
                                            %>
                                        </select>
                                    </div>
                                </form>
                            </div>
                            <div class="col-lg-6 col-md-6">
                                <form role="form">
                                    <div class="form-group">
                                        <label>Loan Status</label>
                                        <select class="form-control" id="StatusSelect">
                                            <option value="">Select...</option>
                                            <option value="CHECKEDOUT">Out</option>
                                            <option value="RETURNED">Returned</option>
                                        </select>
                                    </div>
                                </form>
                                <button type="button" class="btn btn-primary" onclick="GetLoans();">Submit</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="widget-foot">

                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-12">
            <div class="widget wgreen">
                <div class="widget-head">

                </div>
                <div class="widget-content">
                    <div class="padd">
                        <!-- Form Here -->
                        <div id="rslts">
                            <table class="table table-hover" id="rsltTbl">
							    <thead>
								    <tr>
                                        <th>Inventory Id</th>
                                        <th>Book</th>
                                        <th>Student</th>
                                        <th>Status</th>
                                        <th>Checkout Date</th>
									</tr>
								</thead>
								<tbody>
									
								</tbody>
							</table>
                        </div>
                    </div>
                </div>
                <div class="widget-foot">

                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ModalContent" Runat="Server">

</asp:Content>

