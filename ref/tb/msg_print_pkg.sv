//===============================================================================
//                            COPYRIGHT NOTICE
//  Copyright 2000-2023 (c) Lattice Semiconductor Corporation
//  ALL RIGHTS RESERVED
//  This confidential and proprietary software may be used only as authorised by
//  a licensing agreement from Lattice Semiconductor Corporation.
//  The entire notice above must be reproduced on all authorized copies and
//  copies may only be made to the extent permitted by a licensing agreement from
//  Lattice Semiconductor Corporation.
//
//  Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
//  5555 NE Moore Court                      408-826-6000 (other locations)
//  Hillsboro, OR 97124                      web  : http://www.latticesemi.com/
//  U.S.A                                    email: techsupport@latticesemi.com
//===============================================================================
//
//  Project          :  
//  File             :  msg_print_pkg.sv
//  Version          :  v1.0
//  Title            :  package for message printing during simulation
//                      
//  Description      :  
//
//                      
//  Addt'l info      :  
//  Version history  :  
//
//===============================================================================

package msg_print_pkg;

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

