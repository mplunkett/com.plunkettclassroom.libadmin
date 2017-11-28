<%@ Page Title="" Language="C#" MasterPageFile="~/Main.master" AutoEventWireup="true" CodeFile="BookAdd.aspx.cs" Inherits="BookAdd" %>
<asp:Content ID="Content3" ContentPlaceHolderID="pagejs" Runat="Server">
    <script type="text/javascript">
        $(document).ready(function () {
            $("#LoadingImg1").hide();
        });

        function AdjustInventory() {
            var classId = $("#LoggedClassVal").val();
            var InvInput = $("#BookInv").val();
            var InvCurrent = $("#CurrentInventory").val();
            var BookId = $("#BookRid").val();

            $.ajax({
                type: "POST",
                url: "BookAdd.aspx/InventoryAdjust",
                data: "{NewInv: '" + InvInput + "', OldInv: '" + InvCurrent + "', rid: '" + BookId + "', classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    $("#InventoryBtn").html("");
                    var resp = msg.d;
                    var InvCount = resp;
                    $("#CurrentInventory").val(InvCount);
                    var InvDisplay = "<input type='number' id='BookInv' value=" + InvCount + " min=" + InvCount + " class='form-control' onchange='InventoryChange();' />"
                    $("#InvCount").html(InvDisplay);
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);
                },
                async: false
            });
        }

        function InventoryChange() {
            $("#InventoryBtn").html("");
            var InvInput = $("#BookInv").val();
            var InvCurrent = $("#CurrentInventory").val();
            if (InvInput != InvCurrent) {
                var ButtonDisplay = "<button type='button' onclick='AdjustInventory();' class='btn btn-sm btn-primary'>Add Inventory</button>";
                $("#InventoryBtn").html(ButtonDisplay);
            }
        }

        function GetBook() {
            $("#SubmitBtn").hide();
            $("#LoadingImg1").show();            
            $("#InvCount").html('');

            var classId = $("#LoggedClassVal").val();
            var isbnNo = $("#isbn").val();
            if (isbnNo.length != 10 && isbnNo.length != 13) {
                alert("Please enter either 10 or 13 digit ISBN!");
                $("#SubmitBtn").show();
                $("#LoadingImg1").hide();
                return;
            }
            $.ajax({
                type: "POST",
                url: "BookAdd.aspx/SearchISBN",
                data: "{val: '" + isbnNo + "', classId: '" + classId + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var resp = msg.d;
                    if (resp == "X") {
                        alert("ISBN not found in WebService. Please add manually");
                        //alert(resp);
                    }
                    else {
                        var retObj = jQuery.parseJSON(resp);
                        $("#BookRid").val(retObj.rid);
                        $("#BookTitle").val(retObj.BookTitle);
                        $("#BookPublisher").val(retObj.PublisherName);
                        var InvCount = retObj.InventoryCount;
                        $("#CurrentInventory").val(InvCount);

                        var InvDisplay = "<input type='number' id='BookInv' value=" + InvCount + " min=" + InvCount + " class='form-control' onchange='InventoryChange();' />"
                        $("#InvCount").html(InvDisplay);
                    }
                    $("#SubmitBtn").show();
                    $("#LoadingImg1").hide();                    
                },
                error: function (XMLHttpRequest, textStatus, exception) {
                    alert("Ajax failure\nBOOOO \n" + exception);

                    $("#SubmitBtn").show();
                    $("#LoadingImg1").hide();
                },
                async: true
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="pagetitle" Runat="Server">
    <h2 class="pull-left"><i class="fa fa-book"></i> Add Books API Search</h2>
    <div class="clearfix"></div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
	<div class="row">
	    <div class="col-md-12">
		    <div class="widget wgreen">
			    <div class="widget-head">
				    <div class="pull-left">ISBN Search</div>
		            <div class="widget-icons pull-right">
		                <i class="fa fa-search"></i>
		            </div>
		            <div class="clearfix"></div>
			    </div>
			    <div class="widget-content">
				    <div class="padd">
					    <!--Form here-->
				        <form class="form-horizontal" role="form">
				            <div class="form-group">
					            <label class="col-lg-2 control-label">ISBN</label>
					            <div class="col-lg-5">
					                <input type="text" id="isbn" class="form-control" placeholder="isbn..." />
					            </div>
                                <div class="col-lg-3 col-lg-offset-1" id="WaitDiv">

                                </div>
				            </div>
				            <div class="form-group">
				                <div class="col-lg-offset-2 col-lg-6" id="LoadButton">
				         	        <button type="button" id="SubmitBtn" onclick="GetBook();" class="btn btn-sm btn-primary">Submit</button>
                                    <img src="img/loading.gif" alt="Loading..." id="LoadingImg1" style="height:45px;width:45px;"/>                                   
				                </div>
				            </div>
				        </form>
				    </div>
			    </div>
			    <div class="widget-foot">

			    </div>
		    </div>
	    </div>
	</div>
	<div class="row">
	    <div class="col-md-12">
	        <div class="widget wgreen">
			    <div class="widget-head">
                    Results
				</div>
				<div class="widget-content">
				    <div class="padd">
					<!--Form here-->
					    <div id="results">
                            <form class="form-horizontal" role="form">
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Book Id</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="BookRid" class="form-control" value="" readonly />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Title</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="BookTitle" class="form-control" value="" readonly />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Publisher</label>
                                    <div class="col-lg-7">
                                        <input type="text" id="BookPublisher" class="form-control" value="" readonly />
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-lg-2 control-label">Inventory Count</label>
                                    <input type="hidden" id="CurrentInventory" value="" />
                                    <div class="col-lg-7" id="InvCount">

                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-lg-offset-2 col-lg-6" id="InventoryBtn">

                                    </div>
                                </div>
                            </form>
						</div>
					</div>
				</div>
				<div class="widget-foot">
				</div>
			</div>
        </div>
	</div>
</asp:Content>

