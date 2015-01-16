﻿$(function () {
    $("#AddNewPerson").live("click", function (ev) {
        ev.preventDefault();
        var o = $("#newattend div.newattend").clone();
        var i = $("#nextid").val();
        var name = $("#familyattendname").val();
        $(o).attr("id", i);
        $(o).find('input').each(function() {
            this.name = this.name.replace('{0}', name+'['+i+']');
        });
        $("#nextid").val(parseInt(i) + 1);
        $("#added-people").append(o);
        return false;
    });
    //$("#dob").datepicker($.dpoptions);
    $.dodate = function (bd) {
        var re0 = /^(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])((19|20)?[0-9]{2})$/i;
        var re = /^(0?[1-9]|1[012])[\/-](0?[1-9]|[12][0-9]|3[01])[\/-]((19|20)?[0-9]{2})$/i;
        var m = re0.exec(bd);
        if (m == null)
            m = re.exec(bd);
        if (m == null)
            return;

        var y = parseInt(m[3]);
        if (y < 1000)
            if (y < 50) y = y + 2000; else y = y + 1900;
        var bday = new Date(y, m[1] - 1, m[2]);
        var tday = new Date();
        if (bday > tday)
            bday = new Date(y - 100, m[1] - 1, m[2]);

        var by = bday.getFullYear();
        var bm = bday.getMonth();
        var bd = bday.getDate();
        var age = 0;
        while (bday <= tday) {
            bday = new Date(by + age, bm, bd);
            age++;
        }
        return age - 2;
    };
    $('form.DisplayEdit input.dob').live("blur", function () {
        var f = $(this).closest('form');
        $("#age", f).text($.dodate($(this).val()));
    });
    $("form.DisplayEdit .submitbutton, .submitlink, .submitbutton.ajax").live('click', function (ev) {
        ev.preventDefault();
        var f = $(this).closest('form');
        var q = f.serialize();
        $.refreshenabled = true;
        $.post($(this).attr('href'), q, function (ret) {
            if (ret.charAt(0) === '/') {
                $("body").html("<p>Please wait...</p>");
                window.location = ret;
                return;
            }
            $(f).html(ret).ready(function () {
                $.InstructionsShow();
                if ($("#submitit").data("onlyoneallowed") === true) {
                    f.submit();
                } else {
                    if($('div.panel:last-child').length > 0)
                        $('body, html').animate({scrollTop:$('div.panel:last-child').offset().top}, 'fast');
                }
            });
        });
        return false;
    });
    $.ShowPaymentInfo = function () {
        var v = $("input[name=Type]:checked").val();
        $("div.Card").hide();
        $("div.Bank").hide();
        $("div.accountinfo").hide();
        if (v === 'C') {
            $("div.Card").show();
            $("div.accountinfo").show();
        } else if (v === 'B') {
            $("div.Bank").show();
            $("div.accountinfo").show();
        }
    };
    $.InstructionsShow = function () {
        $("div.instructions").hide();
        if ($("#selectfamily").attr("id")) {
            $("div.instructions.select").show();
        }
        else if ($("#personedit").attr("id")) {
            $("#fillout").hide();
            $("div.instructions.find").show();
        }
        else if ($("#otheredit").attr("id")) {
            $("div.instructions.options").show();
            initializeSpecialFunds();
        }
        else if ($("#specialedit").attr("id")) {
            $("div.instructions.special").show();
        }
        else if ($("#username").attr("id")) {
            $("#username").focus();
            $("div.instructions.login").show();
        }
        else if ($("#submitit").attr("id")) {
            $("div.instructions.submit").show();
        }
        else if ($("#sorry").attr("id")) {
            $("div.instructions.sorry").show();
        }

        if ($("#allowcc").val())
            $.ShowPaymentInfo();
    };
//    $("form.DisplayEdit").submit(function () {
//        if (!$("#submitit").val())
//            return false;
//        $("#submitit").attr("disabled", "true");
//        return true;
//    });
    $("form.DisplayEdit a.cancel").live('click', function (ev) {
        ev.preventDefault();
        var f = $(this).closest('form');
        var q = f.serialize();
        $.post($(this).attr('href'), q, function (ret) {
            if (ret == 'refresh')
                location.reload();
            $(f).html(ret).ready(function() {
                $('body, html').animate({ scrollTop: $('form').offset().top }, 'fast');
            });
        });
        return false;
    });
    $("#copy").live("click", function () {
        $("input[name$='.emcontact']:last").val($("input[name$='.emcontact']:hidden:last").val());
        $("input[name$='.emphone']:last").val($("input[name$='.emphone']:hidden:last").val());
        $("input[name$='.insurance']:last").val($("input[name$='.insurance']:hidden:last").val());
        $("input[name$='.policy']:last").val($("input[name$='.policy']:hidden:last").val());
        $("input[name$='.doctor']:last").val($("input[name$='.doctor']:hidden:last").val());
        $("input[name$='.docphone']:last").val($("input[name$='.docphone']:hidden:last").val());
        $("input[name$='.mname']:last").val($("input[name$='.mname']:hidden:last").val());
        $("input[name$='.fname']:last").val($("input[name$='.fname']:hidden:last").val());
        $("input[name$='.paydeposit']:last").val($("input[name$='.paydeposit']:hidden:last").val());
        return false;
    });
    $.InstructionsShow();
    $.validator.addMethod("money", function (value, element) {
        var ret = /^(\d+(\.\d{0,2})?)?$/.test(value);
        return ret;
    }, 'no $ or commas');
    $('form.DisplayEdit,#managegivingform').validate({
        errorClass: "alert-danger",
        highlight: function(element, errorClass, validClass) {
            $(element).addClass(errorClass).removeClass(validClass);
        },
        unhighlight: function(element, errorClass, validClass) {
            $(element).removeClass(errorClass).addClass(validClass);
        },
        submitHandler: function(form) {
            if (!$("#submitit").val())
                return false;
            $("#submitit").attr("disabled", "true");
            form.submit();
            return false;
        }
    });
    function updateTotal() {
        var sum = 0;
        $("input.sum").each(function () {
            if (!isNaN(this.value) && this.value.length != 0) {
                sum += parseFloat(this.value);
            }
        });
        $("#total").html(sum.toFixed(2));
    }
    $("input.sum").live("change", function () {
        updateTotal();
    });
    $("input[name=Type]").live("change", $.ShowPaymentInfo);

    $("#password").live("keypress", function (e) {
        if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
            $('#loginbt').click();
            return false;
        }
        return true;
    });
    $.refreshenabled = false; // false until something happens
    $(document).bind("idle.idleTimer", function () {
        if ($.refreshenabled)
            window.location.href = $.timeoutUrl;
        else
            $.idleTimer($.tmout);
    });

    if ($('input:text:not([value=""])').length == 0)
        $(document).bind("keydown", function () {
            $(document).unbind("keydown");
            $.idleTimer($.tmout);
        });
    else
        $.idleTimer($.tmout);

    // if we are coming back to this page to continue a registration, 
    // check to see if we should be on our way to the next step
    if ($("#submitit").attr("onlyoneallowed") == "true" && $(".input-validation-error", $("#completeReg")).length === 0) {
        $("#completeReg").submit();
    }

    // special giving funds
    function getFundPrefix() {
        var prefix = '';
        if (typeof specialGivingFundsPrefix !== "undefined") {
            prefix = specialGivingFundsPrefix + '.';
        }
        return prefix;
    }

    function addFundRow(id, text) {
        var rowId = '#special-funds tbody tr#' + id;
        if ($(rowId).length) {
            // only set focus to existing row.
            setDelayedFocus($(rowId).find('input:text'));
        } else {
            var i = $('#funds tbody tr').length + $('#special-funds tbody tr').length;
            var fundIndexer = getFundPrefix() + 'FundItem[' + i + ']';
            var inputKey = fundIndexer + '.Key';
            var inputValue = fundIndexer + '.Value';
            $('#special-funds > tbody:last').append('<tr id="' + id + '"><td style="width: 10px;"><a href="#" tabindex="-1" class="remove-fund"><span class="fa fa-trash-o"></span></a></td><td>' + text + '</td><td><div class="pull-right"><input type="hidden" name="' + inputKey + '" value="' + id + '"><input name="' + inputValue + '" type="text" class="form-control narrow sum money"/></div></td></tr>');

            setDelayedFocus($('input[name="' + inputValue + '"]'));
        }
    }

    function setDelayedFocus($element) {
        // set focus after 200 milliseconds.
        var timeoutId = window.setTimeout(function () {
            $element.focus();
            window.clearTimeout(timeoutId);
        }, 200);
    }

    function initializeSpecialFunds() {
        if ($('#special-funds-list').length) {

            $('input:text').first().focus();

            $('#special-funds-list').select2({
                placeholder: 'Select a Fund'
            });

            $('#special-funds-list').on('change', function (e) {
                addFundRow(e.added.id, e.added.text);
                $('#special-funds-list').select2('val', '');
            });

            $(document).on("click", "a.remove-fund", function (e) {
                e.preventDefault();
                $(this).closest('tr').remove();
                var startingIndex = $('#funds tbody tr').length;
                var prefix = getFundPrefix();
                _($('#special-funds tbody tr')).each(function (item, index) {
                    var fundIndex = startingIndex + index;
                    var fundIndexer = prefix + 'FundItem[' + fundIndex + ']';
                    var inputKey = fundIndexer + '.Key';
                    var inputValue = fundIndexer + '.Value';
                    $('input', item)[0].name = inputKey;
                    $('input', item)[1].name = inputValue;
                });
                updateTotal();
            });
        }
    }

    initializeSpecialFunds();

    $('#stop-manage-giving').click(function(e) {
        e.preventDefault();
        if (confirm("This will cancel your recurring giving and stop all payments. Are you sure?")) {
            var postData = {
                peopleId: $('#pid').val(),
                orgId: $('#orgid').val()
            };
            $.post('/OnlineReg/RemoveManagedGiving/', postData).then(function(data) {
                window.location.href = data.Url;
            });
        }
    });
});
