<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>
<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            var classId = $("#LoggedClassVal").val();
            var dataString = "{classId: '" + classId + "'}";

            // get popular books
            $.ajax({
                type: "POST",
                url: "Default.aspx/GetPopularBooks",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "X") {
                        var retObj = jQuery.parseJSON(resp);
                        var elements = "";
                        $.each(retObj, function (key, value) {
                            var element = "";
                            element += "<tr>";
                            element += "<td>" + value.BookTitle + "</td>";
                            element += "<td>" + value.LoanCount + "</td>";
                            element += "</tr>";
                            elements += element;
                        });
                        $("#poptbl tbody").html(elements);
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });

            // get loan length
            $.ajax({
                type: "POST",
                url: "Default.aspx/GetLoanLength",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp != "NA") {
                        $("#loanlength").html("<h2>" + resp + " Days</h2>");
                    }
                    else {
                        $("#loanlength").html("<h2>N/A</h2>");
                    }
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });

            // get donut data
            var donutData = "";
            $.ajax({
                type: "POST",
                url: "Default.aspx/GetInventoryDonut",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    donutData = jQuery.parseJSON(resp);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });

            Morris.Donut({
                element: 'inventorydonut',
                data:donutData,
                resize: true
            });


            // get bar chart data
            var barchartData = "";
            $.ajax({
                type: "POST",
                url: "Default.aspx/GetMonthLoans",
                data: dataString,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;                   
                    barchartData = jQuery.parseJSON(resp);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });

            Morris.Bar({
                element: 'loanbymonth',
                data: barchartData,
                xkey: 'LoanMonth',
                ykeys: ['LoanCount'],
                labels: ['Loan Count'],
                hideHover: 'auto',
                resize: true
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pagetitle" Runat="Server">
    <h2 class="pull-left"><i class="fa fa-dashboard"></i> Dashboard</h2>
    <div class="clearfix"></div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
    <div class="row">
        <div class="col-lg-12">

        </div>
    </div>
    <div class="row">
        <div class="col-lg-4 col-md-4">
            <div class="widget wgreen">
                <div class="widget-head">
                    Most Popular Titles
                </div>
                <div class="widget-content">
				    <div class="padd">
                        <div id="popularbooks">
                            <table class="table" id="poptbl">
                                <thead>
                                    <tr>
                                        <th>Title</th>
                                        <th>Loans</th>
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
        <div class="col-lg-4 col-md-4">
            <div class="widget wgreen">
                <div class="widget-head">
                    Average Loan Time
                </div>
                <div class="widget-content">
				    <div class="padd">
                        <div id="loanlength">

                        </div>
                    </div>
                </div>
				<div class="widget-foot">
				</div>
            </div>
        </div>
        <div class="col-lg-4 col-md-4">
            <div class="widget wgreen">
                <div class="widget-head">
                    Inventory By Status
                </div>
                <div class="widget-content">
				    <div class="padd">
                        <div id="inventorydonut">

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
                    Loans By Month
                </div>
                <div class="widget-content">
				    <div class="padd">
                        <div id="loanbymonth">

                        </div>
                    </div>
                </div>
				<div class="widget-foot">
				</div>
            </div>
        </div>
    </div>
</asp:Content>
