<?php
include_once '../config/database.php';

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Get posted data
    $data = json_decode(file_get_contents("php://input"));
    
    // Check if data is valid
    if (!empty($data->user_id) && !empty($data->otp_code)) {
        // Check if OTP exists and is valid
        $otp_query = "SELECT id, user_id, otp_code, expires_at, is_verified FROM otp_verifications WHERE user_id = ? AND otp_code = ?";
        $otp_stmt = $db->prepare($otp_query);
        $otp_stmt->bindParam(1, $data->user_id);
        $otp_stmt->bindParam(2, $data->otp_code);
        $otp_stmt->execute();
        
        if ($otp_stmt->rowCount() > 0) {
            $otp = $otp_stmt->fetch(PDO::FETCH_ASSOC);
            
            // Check if OTP is already verified
            if ($otp['is_verified'] == 1) {
                http_response_code(400);
                echo json_encode(array(
                    "success" => false,
                    "message" => "OTP already verified"
                ));
            } else {
                // Check if OTP is expired
                $current_time = date('Y-m-d H:i:s');
                if ($current_time > $otp['expires_at']) {
                    http_response_code(400);
                    echo json_encode(array(
                        "success" => false,
                        "message" => "OTP has expired"
                    ));
                } else {
                    // Mark OTP as verified
                    $update_otp_query = "UPDATE otp_verifications SET is_verified = 1 WHERE id = ?";
                    $update_otp_stmt = $db->prepare($update_otp_query);
                    $update_otp_stmt->bindParam(1, $otp['id']);
                    
                    if ($update_otp_stmt->execute()) {
                        // Update driver status to active
                        $update_driver_query = "UPDATE drivers SET status = 'active' WHERE user_id = ?";
                        $update_driver_stmt = $db->prepare($update_driver_query);
                        $update_driver_stmt->bindParam(1, $data->user_id);
                        
                        if ($update_driver_stmt->execute()) {
                            http_response_code(200);
                            echo json_encode(array(
                                "success" => true,
                                "message" => "OTP verified successfully. Account activated."
                            ));
                        } else {
                            http_response_code(500);
                            echo json_encode(array(
                                "success" => false,
                                "message" => "Unable to activate account"
                            ));
                        }
                    } else {
                        http_response_code(500);
                        echo json_encode(array(
                            "success" => false,
                            "message" => "Unable to verify OTP"
                        ));
                    }
                }
            }
        } else {
            http_response_code(400);
            echo json_encode(array(
                "success" => false,
                "message" => "Invalid OTP"
            ));
        }
    } else {
        // Missing data
        http_response_code(400);
        echo json_encode(array(
            "success" => false,
            "message" => "User ID and OTP code are required"
        ));
    }
} else {
    // Invalid request method
    http_response_code(405);
    echo json_encode(array(
        "success" => false,
        "message" => "Method not allowed"
    ));
}
?>
