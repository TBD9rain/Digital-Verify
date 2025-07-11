//==================================================================================================
//
//  Project         :   Digital Verify
//  Version         :   v1.0.0
//  Title           :   msg_log_pkg
//
//  Description     :   message print and log package with message grading
//
//  Additional info :
//  Author          :   TBD9rain
//  Email           :
//
//==================================================================================================

package msg_log_pkg;

    typedef enum {INFO, WARN, ERROR, FATAL}     message_t  ;
    typedef enum {LOW, MEDIUM, HIGH, HIGHEST}   severity_t ;
    typedef enum {LOG, STOP, EXIT}              action_t   ;

    static  severity_t  svrt_thold      = LOW;
    static  string      log_file_name   = "message_printed.log";

    function automatic void print_msg(string src, string msg,
        message_t m_type = INFO, severity_t svrt = LOW, action_t act = LOG);

        integer     fid_log     ;
        string      msg_print   ;

        msg_print   = $sformatf("@%0t [%s] %s: %s\n", $time, m_type, src, msg);

        if (svrt >= svrt_thold) begin
            $write(msg_print);
        end

        fid_log     = $fopen(log_file_name, "a");
        $fwrite(fid_log, msg_print);
        $fclose(fid_log);

        if (act == STOP) begin
            $stop(2);
        end
        else if (act == EXIT) begin
            $finish(2);
        end
    endfunction

    function automatic void clean_msg_log();
        integer     fid_log     ;

        fid_log = $fopen(log_file_name, "w");
        $fclose(fid_log);
    endfunction


endpackage

