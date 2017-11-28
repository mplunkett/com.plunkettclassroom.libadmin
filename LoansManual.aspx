<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="LoansManual.aspx.cs" Inherits="LoansManual" %>

<asp:Content ID="Content4" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        function ShowBookDetails() {
            var bookId = $("#BookId").val();
            if (!$.isNumeric(bookId)) {
                alert("Please enter numeric Id");
                return;
            }
            $("#SelectedBook").val(bookId);
            ShowBook(bookId);
        }

        function ShowBook(bookRid) {
            var classId = $("#LoggedClassVal").val();            
            $("#BookTitle").html("");
            $("#ResultDiv").html("");
            $.ajax({
                type: "POST",
                url: "LoansManual.aspx/GetInventoryDetail",
                data: "{bookId: '" + bookRid + "', classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#ResultDiv").html("");
                    var resp = msg.d;
                    if (resp != "X") {
                        var retObj = jQuery.parseJSON(resp);
                        var invStatus = retObj.InventoryStatus;
                        if (invStatus == "UNKNOWN") {
                            $("#ResultDiv").html("Inventory Not Found");
                        }
                        else {
                            $("#BookTitle").html(retObj.BookTitle + " is " + invStatus);
                            if (invStatus == "IN") {
                                // give form for checking book out
                                var element = "";
                                element += "<form role='form'>";
                                element += "<div class='form-group'>";
                                element += "<label>Select Student</label>";
                                element += "<select class='form-control' id='StudentSelect'>";
                                element += "</select>";
                                element += "</div>";
                                element += "</form>";
                                element += "<button type='button' class='btn btn-primary' onclick='CheckOutBook();'>Check Out!</button>";
                                $("#ResultDiv").html(element);
                                GetStudentSelect();
                            }
                            else {
                                //give form for checking book in
                                var element = "";
                                element += "<form role='form'>";
                                element += "<div class='form-group'>";
                                element += "<label>Checked out to: " + retObj.LoanStudent + "</label>";
                                element += "</div>";
                                element += "</form>";
                                element += "<button type='button' class='btn btn-primary' onclick='CheckInBook(" + retObj.LoanId + ");'>Check In!</button>";
                                $("#ResultDiv").html(element);
                            }
                        }
                    }
                    else {
                        $("#ResultDiv").html("Error in operation");
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function CheckOutBook() {
            var bookId = $("#SelectedBook").val();
            var stuId = $("#StudentSelect").val();
            if (stuId == "") {
                alert("Please select student");
                return;
            }

            $.ajax({
                type: "POST",
                url: "LoansManual.aspx/CheckOutBook",
                data: "{stuId: '" + stuId + "', bookId: '" + bookId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "X") {
                        ShowBook(bookId);
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function CheckInBook(rid) {
            var bookId = $("#SelectedBook").val();
            $.ajax({
                type: "POST",
                url: "LoansManual.aspx/CheckInBook",
                data: "{loanId: '" + rid + "', bookId: '" + bookId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "X") {
                        ShowBook(bookId);
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function GetStudentSelect() {
            var classId = $("#LoggedClassVal").val();
            $.ajax({
                type: "POST",
                url: "LoansManual.aspx/GetStudents",
                data: "{classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "X") {
                        $("#StudentSelect").html("");
                        $("#StudentSelect").append("<option value=''>Select...</option>")
                        var retObj = jQuery.parseJSON(resp);
                        $.each(retObj, function (key, value) {
                            var element = "";
                            element += "<option value='" + value.rid + "'>" + value.StudentName + "</option>";
                            $("#StudentSelect").append(element);
                        });
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
    <h2 class="pull-left"><i class="fa fa-bar-chart-o"></i> Check In/Out</h2>
    <div class="clearfix"></div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="row">
        <div class="col-lg-3 col-md-3">
            <div class="widget wgreen">
                <div class="widget-head">                    
				    <div class="pull-left">Book Id</div>
		            <div class="widget-icons pull-right">
		                <i class="fa fa-search"></i>
		            </div>
		            <div class="clearfix"></div>
                </div>
                <div class="widget-content">
                    <div class="padd">
                        <!-- Form Here -->
                        <form role="form">
                            <div class="form-group">
                                <input type="text" id="BookId" class="form-control" value="" placeholder="Book Id..." />
                            </div>
                        </form>
                        <button type="button" class="btn btn-primary" onclick="ShowBookDetails();">Submit</button>
                    </div>
                </div>
                <div class="widget-foot">

                </div>
            </div>
        </div>
        <div class="col-lg-7 col-md-7">
            <div class="widget wgreen">
                <div class="widget-head">
                    <input type="hidden" id="SelectedBook" value="" />
                    Results:&nbsp&nbsp<span id="BookTitle"></span>
                </div>
                <div class="widget-content">
                    <div class="padd">
                        <div id="ResultDiv">

                        </div>
                    </div>
                </div>
                <div class="widget-foot">

                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ModalContent" Runat="Server">
</asp:Content>


