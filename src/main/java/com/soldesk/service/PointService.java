package com.soldesk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.PointMapper;
import com.soldesk.vo.PointTransactionVO;

@Service
public class PointService {

    @Autowired
    private PointMapper pointMapper;

    @Transactional(readOnly = true)
    public int getBalance(int userId){
        return pointMapper.findBalance(userId);
    }

    /** 적립금 내역 (최신순). 잔액과 어긋나면 이 원장이 진실이다. */
    @Transactional(readOnly = true)
    public List<PointTransactionVO> getHistory(int userId){
        return pointMapper.findByUserId(userId);
    }

    @Transactional
    public void use(int userId, int reservationId, int amount){
        if (amount <= 0)  return;
        if (pointMapper.deductPoint(userId, amount) == 0) {
            throw new IllegalArgumentException("적립금 잔액이 부족합니다");            
        }
        writeTx(userId, reservationId, "use", -amount, "예약 결제 사용");
    }

    @Transactional
    public void restore(int reservationId){
        PointTransactionVO used = pointMapper.findByReservationAndType(reservationId, "use");
        if(used == null) return;
        int amount = -used.getAmount();
        pointMapper.addPoint(used.getUserId(), amount);
        writeTx(used.getUserId(), reservationId, "restore", amount, "결제 취소 환급");
    }

    private void writeTx(int userId, Integer reservationId, String txType, int amount, String description){
        PointTransactionVO tx = new PointTransactionVO();
        tx.setUserId(userId);
        tx.setReservationId(reservationId);
        tx.setTxType(txType);
        tx.setAmount(amount);
        tx.setBalanceAfter(pointMapper.findBalance(userId));
        tx.setDescription(description);
        pointMapper.insertTx(tx);
    }

}